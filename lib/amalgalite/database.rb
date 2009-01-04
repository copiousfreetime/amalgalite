#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
require 'amalgalite/statement'
require 'amalgalite/trace_tap'
require 'amalgalite/profile_tap'
require 'amalgalite/type_maps/default_map'

module Amalgalite
  #
  # The encapsulation of a connection to an SQLite3 database.  
  #
  # Example opening and possibly creating a new daabase
  #
  #   db = Amalgalite::Database.new( "mydb.db" )
  #   db.execute( "SELECT * FROM table" ) do |row|
  #     puts row
  #   end
  #
  #   db.close
  #
  # Open a database read only:
  #
  #   db = Amalgalite::Database.new( "mydb.db", "r" )
  #
  #
  class Database

    # Error thrown if a database is opened with an invalid mode
    class InvalidModeError < ::Amalgalite::Error; end

    ##
    # container class for holding transaction behavior constants.  These are the
    # SQLite values passed to a START TRANSACTION SQL statement.
    #
    class TransactionBehavior
      # no read or write locks are created until the first statement is executed
      # that requries a read or a write
      DEFERRED  = "DEFERRED"

      # a readlock is obtained immediately so that no other process can write to
      # the database
      IMMEDIATE = "IMMEDIATE"
      
      # a read+write lock is obtained, no other proces can read or write to the
      # database
      EXCLUSIVE = "EXCLUSIVE"

      # list of valid transaction behavior constants
      VALID     = [ DEFERRED, IMMEDIATE, EXCLUSIVE ]

      # 
      # is the given mode a valid transaction mode
      #
      def self.valid?( mode )
        VALID.include? mode
      end
    end
    
   include Amalgalite::SQLite3::Constants

   # list of valid modes for opening an Amalgalite::Database
   VALID_MODES = {
      "r"  => Open::READONLY,
      "r+" => Open::READWRITE,
      "w+" => Open::READWRITE | Open::CREATE,
    }

    # the low level Amalgalite::SQLite3::Database
    attr_reader :api

    # An object that follows the TraceTap protocol, or nil.  By default this is nil
    attr_reader :trace_tap

    # An object that follows the ProfileTap protocol, or nil.  By default this is nil
    attr_reader :profile_tap

    # An object that follows the TypeMap protocol, or nil.  
    # By default this is an instances of TypeMaps::DefaultMap
    attr_reader :type_map

    ##
    # Create a new Amalgalite database
    #
    # :call-seq:
    #   Amalgalite::Database.new( filename, "w+", opts = {}) -> Database
    #
    # The first parameter is the filename of the sqlite database.  
    # The second parameter is the standard file modes of how to open a file.
    #
    # The modes are:
    #
    # * r  - Read-only
    # * r+ - Read/write, an error is thrown if the database does not already exist
    # * w+ - Read/write, create a new database if it doesn't exist
    #
    # <tt>w+</tt> is the default as this is how most databases will want to be utilized.
    #
    # opts is a hash of available options for the database:
    #
    # * :utf16  option to set the database to a utf16 encoding if creating a database. 
    #
    # By default, databases are created with an encoding of utf8.  Setting this to 
    # true and opening an already existing database has no effect.
    #
    # *NOTE* Currently :utf16 is not supported by Amalgalite, it is planned 
    # for a later release
    #
    #
    def initialize( filename, mode = "w+", opts = {})
      @open           = false
      @profile_tap    = nil
      @trace_tap      = nil
      @type_map       = ::Amalgalite::TypeMaps::DefaultMap.new

      unless VALID_MODES.keys.include?( mode ) 
        raise InvalidModeError, "#{mode} is invalid, must be one of #{VALID_MODES.keys.join(', ')}" 
      end

      if not File.exist?( filename ) and opts[:utf16] then
        raise NotImplementedError, "Currently Amalgalite has not implemented utf16 support"
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
        @encoding = pragma( "encoding" ).first['encoding']
      end
      return @encoding
    end

    ## 
    # return whether or not the database is currently in a transaction or not
    # 
    def in_transaction?
      not @api.autocommit?
    end

    ##
    # return how many rows changed in the last insert, update or delete statement.
    #
    def row_changes
      @api.row_changes
    end

    ##
    # return how many rows have changed since this connection to the database was
    # opened.
    #
    def total_changes
      @api.total_changes
    end

    ##
    # Prepare a statement for execution
    #
    # If called with a block, the statement is yielded to the block and the
    # statement is closed when the block is done.
    #
    #  db.prepare( "SELECT * FROM table WHERE c = ?" ) do |stmt|
    #    list_of_c_values.each do |c|
    #      stmt.execute( c ) do |row|
    #        puts "when c = #{c} : #{row.inspect}"
    #      end
    #    end
    #  end
    #
    # Or without a block:
    #
    #   stmt = db.prepare( "INSERT INTO t1(x, y, z) VALUES ( :
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
    # call-seq:
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
    # turn will call the <tt>logger.debug</tt> method
    #
    #   db.trace_tap = $stderr 
    #
    # This will register the <tt>$stderr</tt> io stream as a trace tap.  Every time a
    # +trace+ event happens then <tt>$stderr.write( msg )</tt> will be called.
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
    # call-seq:
    #   db.profile_tap = obj 
    #
    # Register a profile tap.
    #
    # Registering a profile tap means that the +obj+ registered will have its
    # +profile+ method called with an Integer and a String parameter every time
    # a profile event happens.  The Integer is the number of nanoseconds it took
    # for the String (SQL) to execute in wall-clock time.
    #
    # That is, every time a profile event happens in SQLite the following is
    # invoked:
    #
    #   obj.profile( str, int ) 
    #
    # For instance:
    #
    #   db.profile_tap = Amalgalite::ProfileTap.new( logger, 'debug' )
    # 
    # This will register an instance of ProfileTap, which wraps an logger object.
    # On each +profile+ event the ProfileTap#profile method will be called
    # which in turn will call <tt>logger.debug<tt> with a formatted string containing
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

    ##
    # call-seq:
    #   db.type_map = DefaultMap.new
    #
    # Assign your own TypeMap instance to do type conversions.  The value
    # assigned here must respond to +bind_type_of+ and +result_value_of+
    # methods.  See the TypeMap class for more details.
    #
    #
    def type_map=( type_map_obj )
      %w[ bind_type_of result_value_of ].each do |method|
        unless type_map_obj.respond_to?( method )
          raise Amalgalite::Error, "#{type_map_obj.class.name} cannot be used to do type mapping.  It does not respond to '#{method}'"
        end
      end
      @type_map = type_map_obj
    end

    ##
    # :call-seq:
    #   db.schema( dbname = "main" ) -> Schema
    # 
    # Returns a Schema object  containing the table and column structure of the
    # database.
    #
    def schema( dbname = "main" ) 
      @schema ||= ::Amalgalite::Schema.new( self, dbname )
    end

    ##
    # :call-seq:
    #   db.reload_schema! -> Schema
    #
    # By default once the schema is obtained, it is cached.  This is here to
    # force the schema to be reloaded.
    #
    def reload_schema!( dbname = "main" )
      @schema = nil
      schema( dbname )
    end

    ##
    # Run a pragma command against the database
    # 
    # Returns the result set of the pragma
    def pragma( cmd, &block )
      execute("PRAGMA #{cmd}", &block)
    end

    ##
    # Begin a transaction.  The valid transaction types are:
    #
    # DEFERRED:: no read or write locks are created until the first
    #            statement is executed that requries a read or a write
    # IMMEDIATE:: a readlock is obtained immediately so that no other process
    #             can write to the database
    # EXCLUSIVE:: a read+write lock is obtained, no other proces can read or
    #             write to the database
    #
    # As a convenience, these are constants available in the
    # Database::TransactionBehavior class.
    #
    # Amalgalite Transactions are database level transactions, just as SQLite's
    # are.
    #
    # If a block is passed in, then when the block exits, it is guaranteed that
    # either 'COMMIT' or 'ROLLBACK' has been executed.  
    #
    # If any exception happens during the transaction that is caught by Amalgalite, 
    # then a 'ROLLBACK' is issued when the block closes.  
    #
    # If no exception happens during the transaction then a 'COMMIT' is
    # issued upon leaving the block.
    #
    # If no block is passed in then you are on your own.
    #
    # Nested transactions are not supported by SQLite, but they are faked here.
    # If you call transaction within a transaction, no new transaction is
    # started, the current one is just continued.
    # 
    def transaction( mode = TransactionBehavior::DEFERRED )
      raise Amalgalite::Error, "Invalid transaction behavior mode #{mode}" unless TransactionBehavior.valid?( mode )

      # if already in a transaction, no need to start a new one.
      if not in_transaction? then
        execute( "BEGIN #{mode} TRANSACTION" )
      end

      if block_given? then
        begin
          return ( yield self )
        ensure
          if $! then
            rollback
            raise $!
          else
            commit
          end
        end
      else
        return in_transaction?
      end
    end

    ##
    # Commit a transaction
    #
    def commit
      execute( "COMMIT" ) if in_transaction?
    end

    ##
    # Rollback a transaction
    #
    def rollback
      execute( "ROLLBACK" ) if in_transaction?
    end

    ##
    # call-seq: 
    #   db.register_functor( MyScalerFunctor ) -> nil
    #   db.register_functor( MyAggregateFunctor ) -> nil
    #
    # register a Class to be used as an SQL Function
    #
    def register_functor( klass )
      if klass.ancestors.include?( Amalgalite::ScalarFunctor ) then
        @api.create_

      end

    end

  end
end

