#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
require 'amalgalite/statement'
require 'amalgalite/trace_tap'
require 'amalgalite/profile_tap'

module Amalgalite
  class Database

    class InvalidModeError < ::Amalgalite::Error; end
    ##
    # Create a new Amalgalite database
    #
    # :call-seq:
    #   Amalgalite::Database.new( filename, "r", opts = {}) -> Database
    #
    # The first parameter is the filename of the sqlite database.  
    # The second parameter is the standard file modes of how to open a file.
    #
    # The modes are:
    #   * r  - Read-only
    #   * r+ - Read/write, an error is thrown if the database does not already
    #          exist.
    #   * w+ - Read/write, create a new database if it doesn't exist
    #          This is the default as this is how most databases will want
    #          to be utilized.
    #
    # opts is a hash of available options for the database:
    #
    #   :utf16 : option to set the database to a utf16 encoding if creating 
    #            a database. By default, databases are created with an 
    #            encoding of utf8.  Setting this to true and opening an already
    #            existing database has no effect.
    #
    #
    include Amalgalite::SQLite3::Constants
    VALID_MODES = {
      "r"  => Open::READONLY,
      "r+" => Open::READWRITE,
      "w+" => Open::READWRITE | Open::CREATE,
    }

    attr_reader :api
    attr_reader :trace_tap
    attr_reader :profile_tap

    ##
    # Create a new database 
    #
    def initialize( filename, mode = "w+", opts = {})
      @open        = false
      @profile_tap = nil
      @trace_tap   = nil

      unless VALID_MODES.keys.include?( mode ) 
        raise InvalidModeError, "#{mode} is invalid, must be one of #{VALID_MODES.keys.join(', ')}" 
      end

      if not File.exist?( filename ) and opts[:utf16] then
        @api = Amalgalite::SQLite3::Database.open16( filename )
      else
        @api = Amalgalite::SQLite3::Database.open( filename, VALID_MODES[mode] )
      end
      @open = true
    end

    ##
    # Is the database open or not
    #
    def open?
      @open
    end

    ##
    # Close the database
    #
    def close
      if open? then
        @api.close
      end
    end

    ##
    # Is the database in autocommit mode or not
    #
    def autocommit?
      @api.autocommit?
    end

    ##
    # Return the rowid of the last inserted row
    #
    def last_insert_rowid
      @api.last_insert_rowid
    end

    ##
    # Is the database utf16 or not?  A database is utf16 if the encoding is not
    # UTF-8.  Database can only be UTF-8 or UTF-16, and the default is UTF-8
    #
    def utf16?
      unless @utf16.nil?
        @utf16 = (encoding != "UTF-8") 
      end
      return @utf16
    end

    ## 
    # return the encoding of the database
    #
    def encoding
      unless @encoding
        @encoding = "UTF-8"
        #@encoding = db.pragma( "encoding" )
      end
      return @encoding
    end

    ##
    # Prepare a statement for execution
    #
    # If called with a block, the statement is yielded to the block and the
    # statement is closed when the block is done.
    #
    def prepare( sql )
      stmt = Amalgalite::Statement.new( self, sql )
      if block_given? then
        begin 
          yield stmt
        ensure
          stmt.close
          stmt = nil
        end
      end
      return stmt
    end

    ##
    # Execute a single SQL statement. 
    #
    # If called with a block and there are result rows, then they are iteratively
    # yielded to the block.
    #
    # If no block passed and there are results, then a ResultSet is returned.
    # Otherwise nil is returned.  On an error an exception is thrown.
    #
    # This is just a wrapper around the preparation of an Amalgalite Statement and
    # iterating over the results.
    #
    def execute( sql, *bind_params )
      stmt = prepare( sql )
      stmt.bind( *bind_params )
      if block_given? then
        stmt.each { |row| yield row }
      else
        return stmt.all_rows
      end
    ensure
      stmt.close if stmt
    end

    ##
    # Execute a batch of statements, this will execute all the sql in the given
    # string until no more sql can be found in the string.  It will bind the 
    # same parameters to each statement.  All data that would be returned from 
    # all of the statements is thrown away.
    #
    # All statements to be executed in the batch must be terminated with a ';'
    # Returns the number of statements executed
    #
    #
    def execute_batch( sql, *bind_params) 
      count = 0
      while sql
        prepare( sql ) do |stmt|
          stmt.execute( *bind_params )
          sql =  stmt.remaining_sql 
          sql = nil unless (sql.index(";") and Amalgalite::SQLite3.complete?( sql ))
        end
        count += 1
      end
      return count
    end

    ##
    # clear all the current taps
    #
    def clear_taps!
      self.trace_tap = nil
      self.profile_tap = nil
    end

    ##
    # :call-seq:
    #   db.trace_tap = obj 
    #
    # Register a trace tap.  
    #
    # Registering a trace tap measn that the +obj+ registered will have its
    # +trace+ method called with a string parameter at various times.
    # If the object doesn't respond to the +trace+ method then +write+
    # will be called.
    #
    # For instance:
    #
    #   db.trace_tap = Amalgalite::TraceTap.new( logger, 'debug' )
    # 
    # This will register an instance of TraceTap, which wraps an logger object.
    # On each +trace+ event the TraceTap#trace method will be called, which in
    # turn will call the +logger.debug+ method
    #
    #   db.trace_tap = $stderr 
    #
    # This will register the $stderr io stream as a trace tap.  Every time a
    # +trace+ event happens then +$stderr.write( msg )+ will be called.
    #
    #   db.trace_tap = nil
    #
    # This will unregistere the trace tap
    #
    #
    def trace_tap=( tap_obj )

      # unregister any previous trace tap
      #
      unless @trace_tap.nil?
        @trace_tap.trace( 'unregistered as trace tap' )
        @trace_tap = nil
      end
      return @trace_tap if tap_obj.nil?


      # wrap the tap if we need to
      #
      if tap_obj.respond_to?( 'trace' ) then
        @trace_tap = tap_obj
      elsif tap_obj.respond_to?( 'write' ) then
        @trace_tap = Amalgalite::TraceTap.new( tap_obj, 'write' )
      else
        raise Amalgalite::Error, "#{tap_obj.class.name} cannot be used to tap.  It has no 'write' or 'trace' method.  Look at wrapping it in a Tap instances."
      end

      # and do the low level registration
      #
      @api.register_trace_tap( @trace_tap )

      @trace_tap.trace( 'registered as trace tap' )
    end


    ##
    # :call-seq:
    #   db.profile_tap = obj 
    #
    # Register a profile tap.
    #
    # Registering a profile tap means that the +obj+ registered will have its
    # +profile+ method called with an Integer and a String parameter every time
    # a profile event happens.  The Integer is the number of nanoseconds it took
    # for the String (SQL) to execute in wall-clock time.
    #
    # That is, ever time a profile event happens in SQLite the following is
    # invoked:
    #
    #   obj.profile( str, int ) 
    #
    # For instance:
    #
    #   db.profile_tap = Amalgalite::ProfileTap.new( logger, 'debug' )
    # 
    # This will register an instance of ProfileTap, which wraps an logger object.
    # On each +profile+ eventn the ProfileTap#profile method will be called
    # which in turn will call +logger.debug+ with a formatted string containing
    # the String and Integer from the profile event.
    #
    #   db.profile_tap = nil
    #
    # This will unregister the profile tap
    #
    #
    def profile_tap=( tap_obj )

      # unregister any previous profile tap
      unless @profile_tap.nil?
        @profile_tap.profile( 'unregistered as profile tap', 0.0 )
        @profile_tap = nil
      end
      return @profile_tap if tap_obj.nil?

      if tap_obj.respond_to?( 'profile' ) then
        @profile_tap = tap_obj
      else
        raise Amalgalite::Error, "#{tap_obj.class.name} cannot be used to tap.  It has no 'profile' method"
      end
      @api.register_profile_tap( @profile_tap )
      @profile_tap.profile( 'registered as profile tap', 0.0 )
    end
  end
end

