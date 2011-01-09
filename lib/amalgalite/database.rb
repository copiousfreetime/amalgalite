#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite/statement'
require 'amalgalite/trace_tap'
require 'amalgalite/profile_tap'
require 'amalgalite/type_maps/default_map'
require 'amalgalite/function'
require 'amalgalite/aggregate'
require 'amalgalite/busy_timeout'
require 'amalgalite/progress_handler'
require 'amalgalite/csv_table_importer'

module Amalgalite
  #
  # The encapsulation of a connection to an SQLite3 database.  
  #
  # Example opening and possibly creating a new database
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
  # Open an in-memory database:
  #
  #   db = Amalgalite::MemoryDatabase.new
  #
  class Database

    # Error thrown if a database is opened with an invalid mode
    class InvalidModeError < ::Amalgalite::Error; end

    # Error thrown if there is a failure in a user defined function
    class FunctionError < ::Amalgalite::Error; end

    # Error thrown if there is a failure in a user defined aggregate
    class AggregateError < ::Amalgalite::Error; end

    # Error thrown if there is a failure in defining a busy handler
    class BusyHandlerError < ::Amalgalite::Error; end

    # Error thrown if there is a failure in defining a progress handler
    class ProgressHandlerError < ::Amalgalite::Error; end

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

    # A list of the user defined functions
    attr_reader :functions

    # A list of the user defined aggregates
    attr_reader :aggregates

    ##
    # Create a new Amalgalite database
    #
    # :call-seq:
    #   Amalgalite::Database.new( filename, "w+", opts = {}) -> Database
    #
    # The first parameter is the filename of the sqlite database.  Specifying
    # ":memory:" as the filename creates an in-memory database.
    #
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
      @functions      = Hash.new 
      @aggregates     = Hash.new
      @utf16          = false

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
        @open = false
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
    # SQL escape the input string
    #
    def escape( s )
      Amalgalite::SQLite3.escape( s )
    end

    ##
    # Surround the give string with single-quotes and escape any single-quotes
    # in the string
    def quote( s )
      Amalgalite::SQLite3.quote( s )
    end

    ##
    # Is the database utf16 or not?  A database is utf16 if the encoding is not
    # UTF-8.  Database can only be UTF-8 or UTF-16, and the default is UTF-8
    #
    def utf16?
      return @utf16
      #if @utf16.nil?
      #  @utf16 = (encoding != "UTF-8") 
      #end
      #return @utf16
    end

    ## 
    # return the encoding of the database
    #
    def encoding
      @encoding ||= pragma( "encoding" ).first['encoding']
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
    # If no block is passed, then all the results are returned as an arrayfields
    # instance.  This is an array with field name access.
    #
    # If no block is passed, and there are no results, then an empty Array is
    # returned.
    #
    # On an error an exception is thrown
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
    # Execute a sql statment, and only return the first row of results.  This
    # is a shorthand method when you only want a single row of results from a
    # query.  If there is no result, then return an empty array
    #
    # It is in all other was, exactly like #execute()
    #
    def first_row_from( sql, *bind_params ) 
      stmt = prepare( sql )
      stmt.bind( *bind_params)
      row = stmt.next_row || []
      stmt.close
      return row
    end

    ##
    # Execute an sql statement, and return only the first column of the first
    # row.  If there is no result, return nil.
    #
    # It is in all other ways, exactly like #first_row_from()
    #
    def first_value_from( sql, *bind_params )
      return first_row_from( sql, *bind_params).first
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
      if @schema and @schema.dirty?
        reload_schema!( dbname )
      end
      return @schema
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
    # Nesting a transaaction via the _transaction_ method are no-ops.
    # If you call transaction within a transaction, no new transaction is
    # started, the current one is just continued.
    #
    # True nexted transactions are available through the _savepoint_ method.
    #
    def transaction( mode = TransactionBehavior::DEFERRED, &block )
      raise Amalgalite::Error, "Invalid transaction behavior mode #{mode}" unless TransactionBehavior.valid?( mode )

      # if already in a transaction, no need to start a new one.
      if not in_transaction? then
        execute( "BEGIN #{mode} TRANSACTION" )
      end

      if block_given? then
        begin
          previous_exception = $!
          return ( yield self )
        ensure
          if $! and ($! != previous_exception) then
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
    alias :deferred_transaction :transaction

    # helper for an immediate transaction
    def immediate_transaction( &block )
      transaction( TransactionBehavior::IMMEDIATE, &block )
    end

    # helper for an exclusive transaction
    def exclusive_transaction( &block )
      transaction( TransactionBehavior::EXCLUSIVE, &block )
    end

    ##
    # call-seq: 
    #   db.savepoint( 'mypoint' ) -> db
    #   db.savepoint( 'mypoint' ) do |db_in_savepoint|
    #     ...
    #   end
    #
    # Much of the following documentation is para-phrased from 
    # http://sqlite.org/lang_savepoint.html
    #
    # Savepoints are a method of creating transactions, similar to _transaction_
    # except that they may be nested.
    #
    # * Every savepoint must have a name, +to_s+ is called on the method
    #   argument
    # * A savepoint does not need to be initialized inside a _transaction_.  If
    #   it is not inside a _transaction_ it behaves exactly as if a DEFERRED
    #   transaction had been started.
    # * If a block is passed to _saveponit_ then when the block exists, it is
    #   guaranteed that either a 'RELEASE' or 'ROLLBACK TO name' has been executed.
    # * If any exception happens during the savepoint transaction, then a
    #   'ROLLOBACK TO' is issued when the block closes.
    # * If no exception happens during the transaction then a 'RELEASE name' is
    #   issued upon leaving the block
    #
    # If no block is passed in then you are on your own.
    #
    def savepoint( name )
      point_name = name.to_s.strip
      raise Amalgalite::Error, "Invalid savepoint name '#{name}'" unless point_name and point_name.length > 1
      execute( "SAVEPOINT #{point_name};")
      if block_given? then
        begin
          return ( yield self )
        ensure
          if $! then
            rollback_to( point_name )
            raise $!
          else
            release( point_name )
          end
        end
      else
        return in_transaction?
      end
    end

    ##
    # call-seq:
    #   db.release( 'mypoint' )
    #
    # Release a savepoint.  This is similar to a _commit_ but only for
    # savepoints.  All savepoints up  the savepoint stack and include the name
    # savepoint being released are 'committed' to the transaction.  There are
    # several ways of thinking about release and they are all detailed in the
    # sqlite documentation: http://sqlite.org/lang_savepoint.html
    #
    def release( point_name )
      execute( "RELEASE SAVEPOINT #{point_name}" ) if in_transaction? 
    end

    ##
    # call-seq:
    #   db.rollback_to( point_name )
    #
    # Rollback to a savepoint.  The transaction is not cancelled, the
    # transaction is restarted.
    def rollback_to( point_name )
      execute( "ROLLBACK TO SAVEPOINT #{point_name}" )
    end

    ##
    # Commit a transaction
    #
    def commit
      execute( "COMMIT TRANSACTION" ) if in_transaction?
    end

    ##
    # Rollback a transaction
    #
    def rollback
      execute( "ROLLBACK TRANSACTION" ) if in_transaction?
    end

    ##
    # call-seq:
    #   db.function( "name", MyDBFunction.new )
    #   db.function( "my_func", callable )
    #   db.function( "my_func" ) do |x,y|
    #     .... 
    #     return result
    #   end
    #
    # register a callback to be exposed as an SQL function.  There are multiple
    # ways to register this function:
    #
    # 1. db.function( "name" ) { |a| ... }
    #    * pass +function+ a _name_ and a block.  
    #    * The SQL function _name_ taking _arity_ parameters will be registered, 
    #      where _arity_ is the _arity_ of the block.
    #    * The return value of the block is the return value of the registred
    #      SQL function
    # 2. db.function( "name", callable )
    #    * pass +function+ a _name_ and something that <tt>responds_to?( :to_proc )</tt>
    #    * The SQL function _name_ is registered taking _arity_ parameters is
    #      registered where _arity_ is the _arity_ of +callable.to_proc.call+
    #    * The return value of the +callable.to_proc.call+ is the return value
    #      of the SQL function
    #
    # See also ::Amalgalite::Function
    #
    def define_function( name, callable = nil, &block ) 
      p = ( callable || block ).to_proc
      raise FunctionError, "Use only mandatory or arbitrary parameters in an SQL Function, not both" if p.arity < -1
      db_function = ::Amalgalite::SQLite3::Database::Function.new( name, p )
      @api.define_function( db_function.name, db_function )
      @functions[db_function.signature] = db_function
      nil
    end
    alias :function :define_function

    ##
    # call-seq:
    #   db.remove_function( 'name', MyScalerFunctor.new )
    #   db.remove_function( 'name', callable )
    #   db.remove_function( 'name', arity )
    #   db.remove_function( 'name' )
    #
    # Remove a function from use in the database.  Since the same function may
    # be registered more than once with different arity, you may specify the
    # arity, or the function object, or nil.  If nil is used for the arity, then
    # Amalgalite does its best to remove all functions of given name.
    #
    def remove_function( name, callable_or_arity = nil )
      arity = nil
      if callable_or_arity.respond_to?( :to_proc ) then
        arity = callable_or_arity.to_proc.arity
      elsif callable_or_arity.respond_to?( :to_int ) then
        arity = callable_or_arity.to_int
      end
      to_remove = []

      if arity then
        signature = ::Amalgalite::SQLite3::Database::Function.signature( name, arity ) 
        db_function = @functions[ signature ]
        raise FunctionError, "db function '#{name}' with arity #{arity} does not appear to be defined" unless db_function
        to_remove << db_function
      else
        possibles = @functions.values.select { |f| f.name == name }
        raise FunctionError, "no db function '#{name}' appears to be defined" if possibles.empty?
        to_remove = possibles
      end

      to_remove.each do |db_function|
        @api.remove_function( db_function.name, db_function) 
        @functions.delete( db_function.signature )
      end
    end

    ##
    # call-seq:
    #   db.define_aggregate( 'name', MyAggregateClass )
    #
    # Define an SQL aggregate function, these are functions like max(), min(),
    # avg(), etc.  SQL functions that would be used when a GROUP BY clause is in
    # effect.  See also ::Amalgalite::Aggregate.
    #
    # A new instance of MyAggregateClass is created for each instance that the
    # SQL aggregate is mentioned in SQL.
    #
    def define_aggregate( name, klass )
      db_aggregate = klass
      a = klass.new
      raise AggregateError, "Use only mandatory or arbitrary parameters in an SQL Aggregate, not both" if a.arity < -1
      raise AggregateError, "Aggregate implementation name '#{a.name}' does not match defined name '#{name}'"if a.name != name
      @api.define_aggregate( name, a.arity, klass )
      @aggregates[a.signature] = db_aggregate
      nil
    end
    alias :aggregate :define_aggregate

    ##
    # call-seq:
    #   db.remove_aggregate( 'name', MyAggregateClass )
    #   db.remove_aggregate( 'name' )
    #
    # Remove an aggregate from use in the database.  Since the same aggregate
    # may be refistered more than once with different arity, you may specify the
    # arity, or the aggregate class, or nil.  If nil is used for the arity then
    # Amalgalite does its best to remove all aggregates of the given name
    #
    def remove_aggregate( name, klass_or_arity = nil )
      klass = nil
      case klass_or_arity
      when Integer
        arity = klass_or_arity
      when NilClass
        arity = nil
      else
        klass = klass_or_arity
        arity = klass.new.arity
      end
      to_remove = []
      if arity then
        signature = ::Amalgalite::SQLite3::Database::Function.signature( name, arity )
        db_aggregate = @aggregates[ signature ]
        raise AggregateError, "db aggregate '#{name}' with arity #{arity} does not appear to be defined" unless db_aggregate
        to_remove << db_aggregate
      else
        possibles = @aggregates.values.select { |a| a.new.name == name }
        raise AggregateError, "no db aggregate '#{name}' appears to be defined" if possibles.empty?
        to_remove = possibles
      end

      to_remove.each do |db_aggregate|
        i = db_aggregate.new
        @api.remove_aggregate( i.name, i.arity, db_aggregate )
        @aggregates.delete( i.signature )
      end
    end

    ##
    # call-seq:
    #   db.busy_handler( callable )
    #   db.define_busy_handler do |count|
    #   end
    #   db.busy_handler( Amalgalite::BusyTimeout.new( 30 ) )
    #
    # Register a busy handler for this database connection, the handler MUST
    # follow the +to_proc+ protocol indicating that is will 
    # +respond_to?(:call)+.  This is intrinsic to lambdas and blocks so 
    # those will work automatically.
    #
    # This exposes the sqlite busy handler api to ruby.
    #
    # * http://sqlite.org/c3ref/busy_handler.html
    #
    # The busy handler's _call(N)_ method may be invoked whenever an attempt is
    # made to open a database table that another thread or process has locked.
    # +N+ will be the number of times the _call(N)_ method has been invoked
    # during this locking event.
    #
    # The handler may or maynot be called based upon what SQLite determins.
    #
    # If the handler returns _nil_ or _false_ then no more busy handler calls will
    # be made in this lock event and you are probably going to see an
    # SQLite::Error in your immediately future in another process or in another
    # piece of code.
    #
    # If the handler returns non-nil or non-false then another attempt will be
    # made to obtain the lock, lather, rinse, repeat.
    #
    # If an Exception happens in a busy handler, it will be the same as if the
    # busy handler had returned _nil_ or _false_.  The exception itself will not
    # be propogated further.
    #
    def define_busy_handler( callable = nil, &block )
      handler = ( callable || block ).to_proc
      a = handler.arity
      raise BusyHandlerError, "A busy handler expects 1 and only 1 argument, not #{a}" if a != 1
      @api.busy_handler( handler )
    end
    alias :busy_handler :define_busy_handler

    ##
    # call-seq:
    #   db.remove_busy_handler
    #
    # Remove the busy handler for this database connection.
    def remove_busy_handler
      @api.busy_handler( nil )
    end

    ##
    # call-seq:
    #   db.interrupt!
    #
    # Cause another thread with a handle on this database to be interrupted and
    # return at the earliest opportunity as interrupted.  It is not safe to call
    # this method if the database might be closed before interrupt! returns.
    #
    def interrupt!
      @api.interrupt!
    end

    ##
    # call-seq:
    #   db.progress_handler( 50, MyProgressHandler.new )
    #   db.progress_handler( 25 , callable )
    #   db.progress_handler do
    #     ....
    #     return result
    #   end
    #
    # Register a progress handler for this database connection, the handler MUST
    # follow the +to_proc+ protocol indicating that is will 
    # +respond_to?(:call)+.  This is intrinsic to lambdas and blocks so 
    # those will work automatically.
    #
    # This exposes the sqlite progress handler api to ruby.
    #
    # * http://sqlite.org/c3ref/progress_handler.html
    #
    # The progress handler's _call()_ method may be invoked ever N SQLite op
    # codes.  If the progress handler returns anything that can evaluate to
    # +true+ then current running sqlite statement is terminated at the earliest
    # oppportunity.
    #
    # You can use this to be notified that a thread is still processingn a
    # request.
    #
    def define_progress_handler( op_code_count = 25, callable = nil, &block )
      handler  = ( callable || block ).to_proc
      a = handler.arity
      raise ProgressHandlerError, "A progress handler expects 0 arguments, not #{a}" if a != 0
      @api.progress_handler( op_code_count, handler )
    end
    alias :progress_handler :define_progress_handler

    ##
    # call-seq:
    #   db.remove_progress_handler
    #
    # Remove the progress handler for this database connection.
    def remove_progress_handler
      @api.progress_handler( nil, nil )
    end

    ##
    # call-seq:
    #   db.replicate_to( ":memory:" ) -> new_db
    #   db.replicate_to( "/some/location/my.db" ) -> new_db
    #   db.replicate_to( Amalgalite::Database.new( "/my/backup.db" ) ) -> new_db
    #
    # replicate_to() takes a single argument, either a String or an
    # Amalgalite::Database.  It returns the replicated database object.  If
    # given a String, it will truncate that database if it already exists.
    #
    # Replicate the current database to another location, this can be used for a
    # number of purposes:
    #
    # * load an sqlite database from disk into memory
    # * snaphost an in memory db and save it to disk
    # * backup on sqlite database to another location
    # 
    def replicate_to( location )
      to_db = nil
      case location 
      when String
        to_db = Amalgalite::Database.new( location )
      when Amalgalite::Database
        to_db = location
      else
        raise ArgumentError, "replicate_to( #{location} ) must be a String or a Database" 
      end

      @api.replicate_to( to_db.api )
      return to_db
    end

    ##
    # call-seq:
    #   db.import_csv_to_table( "/some/location/data.csv", "my_table" )
    #   db.import_csv_to_table( "countries.csv", "countries", :col_sep => "|", :headers => %w[ name two_letter id ] )
    #
    #
    # import_csv_to_table() takes 2 required arguments, and a hash of options.  The 
    # first argument is the path to a CSV, the second is the table in which
    # to load the data.  The options has is a subset of those used by CSV
    #
    # * :col_sep - the string placed between each field.  Default is ","
    # * :row_sep - the String appended to the end of each row.  Default is :auto
    # * :quote_char - The character used to quote fields.  Default '"'
    # * :headers - set to true or :first_row if there are headers in this CSV. Default is false.
    #              This may also be an Array.  If that is the case then the
    #              array is used as the fields in the CSV and the fields in the
    #              table in which to insert.  If this is set to an Array, it is
    #              assumed that all rows in the csv will be inserted.
    #
    def import_csv_to_table( csv_path, table_name, options = {} )
      importer = CSVTableImporter.new( csv_path, self, table_name, options )
      importer.run
    end
  end
end

