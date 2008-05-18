#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
#
require 'amalgalite3'
require 'amalgalite/blob'

module Amalgalite
  class Statement

    include ::Amalgalite::SQLite3::Constants

    attr_reader :db
    attr_reader :sql
    attr_reader :api

    #
    # Initialize a new statement on the database.  
    #
    def initialize( db, sql )
      @db = db
      prepare_method =  @db.utf16? ? :prepare16 : :prepare
      @param_positions = {}
      @stmt_api = @db.api.send( prepare_method, sql )
    end

    #
    # reset the Statement back to it state right after the constructor returned,
    # except if any variables have been bound to parameters, those are still
    # bound.
    #
    def reset!
      @stmt_api.reset!
      @column_names = nil
      @param_positions = {}
    end


    ##
    # reset the Statement back to it state right after the constructor returned,
    # AND clear all parameter bindings.
    #
    def reset_and_clear_bindings!
      reset!
      @stmt_api.clear_bindings!
    end

    ##
    # Execute the statement with the given parameters
    #
    # If a block is given, then yield each returned row to the block.  If no
    # block is given then return all rows from the result
    #
    def execute( *params )
      bind( *params )
      if block_given? then
        while row = next_row
          yield row
        end
      else
        all_rows
      end
    end


    ##
    # Bind parameters to the sql statement.
    #
    # Bindings in SQLite can have a number of formats:
    #
    #   ?
    #   ?num
    #   :var
    #   @var
    #   $var
    #
    # Where 'num' is an Integer and 'var'is an alphanumerical variable.
    # They may exist in the SQL for which this Statement was created. 
    #
    # Amalgalite binds parameters to these variables in the following manner:
    # 
    # If bind is passed in an Array, either as +bind( "foo", "bar", "baz")+ or
    # as bind( ["foo", "bar", "baz"] ) then each of the params is assumed to be
    # positionally bound to the statement( ?, ?num ).
    # 
    # If bind is passed a Hash, either as +bind( :foo => 1, :bar => 'sqlite' )+
    # or as bind( { :foo => 1, 'bar' => 'sqlite' }) then it is assumed that each
    # parameter should be bound as a named parameter (:var, @var, $var).
    #
    # If bind is not passed any parameters, or nil, then nothing happens.
    #
    def bind( *params )
      return nil if params.nil? or params.empty?

      if params.first.instance_of?( Hash ) then
        bind_named_parameters( params.first )
      else
        bind_positional_parameters( params )
      end
    end

    ##
    # Bind parameters to the statement based upon named parameters
    #
    def bind_named_parameters( params )
      check_parameter_count!( params.size )
      params.each_pair do | param, value |
        position = param_position_of( param )
        if position > 0 then
          bind_parameter_to( position, value )
        else
          raise "Unable to find parameter '#{param}' in SQL statement [#{sql}]"
        end
      end
    end

    ##
    # Bind parameters to the statements based upon positions. 
    #
    def bind_positional_parameters( params )
      check_parameter_count!( params.size )
      params.each_with_index do |value, index|
        position = index + 1
        bind_parameter_to( position, value )
      end
    end

    ##
    # bind a single parameter to a particular position
    #
    def bind_parameter_to( position, value )
        case value
        when Float
          @stmt_api.bind_double( position, value )
        when Fixnum
          @stmt_api.bind_int( position, value )
        when Bignum
          @stmt_api.bind_int64( position, value )
        when NilClass
          @stmt_api.bind_null( position )
        when ::Amalgalite::Blob
          raise NotImplemented, "Blob binding is not implemented yet"
        else
          @stmt_api.bind_text( position, value.to_s )
        end
    end
      

    ##
    # Find and cache the binding parameter indexes
    #
    def param_position_of( name )
      ns = name.to_s
      unless pos = @param_positions[ns] 
        pos = @param_positions[ns] = @stmt_api.parameter_index( ns )
      end
      return pos
    end

    #
    # Check and make sure that the number of parameters aligns with the number
    # that sqlite expects
    #
    def check_parameter_count!( num )
      expected = @stmt_api.parameter_count
      if num != expected then 
        raise Amalgalite::Error, "#{sql} has #{expected} parameters, but #{num} were passed to bind."
      end
      return expected
    end


    #
    # Iterate over the results of the statement returning each row of results 
    # as a hash by +column_name+.  The column names are the value after an 
    # 'AS' in the query or default chosen by sqlite.  
    #
    def each
      while row = next_row
        yield row
      end
      return self
    end

    #
    # TODO: make this into a Row type object with accessors by index, name and
    # key
    #
    def next_row
      row = {}
      case rc = @stmt_api.step
      when ResultCode::ROW
        column_names.each_with_index do |name, idx|
          row[name] = @stmt_api.column_value( idx )
        end
      when ResultCode::DONE
        row = nil
      else
        raise Amalgalite::SQLite3::Error, 
              "Received unexepcted result code #{rc} : #{Amalgalite::SQLite3::Constants::ResultCode.from_int( rc )}"
      end
      return row
    end

    #
    # Return all rows from the statement as one array
    #
    def all_rows
      rows = []
      while row = next_row
        rows << row
      end
      return rows
    end

    #
    # Inspect the statement and gather all the meta information bout the
    # results, include the name of the column result column and the origin
    # column.  The origin column is the original database.table.column the value
    # comes from
    #
    def result_meta
      unless @result_meta
        meta = []
        column_count.times do |idx|
          column_meta = OpenStruct.new
          column_meta.origin = OpenStruct.new
          column_meta.origin.db_name    = @stmt_api.column_database_name( idx ) 
          column_meta.origin.table_name = @stmt_api.column_table_name( idx ) 
          column_meta.origin.colum_name = @stmt_api.column_origin_name( idx ) 

          column_meta.name = @stmt_api.column_name( idx )
          meta << column_meta 
        end
        @result_meta = meta
      end
      return @result_meta
    end

    #
    # Return the names of the result columsn for the query.  These will be the
    # keys in the hash returned by +each+.
    #
    def column_names
      unless @column_names
        @column_names = result_meta.collect { |m| m.name }
      end
      return @column_names
    end

    #
    # Return any unsued SQL from the statement
    #
    def remaining_sql
      @stmt_api.remaining_sql
    end


    #
    # return the number of columns in the result of this query
    #
    def column_count
      @stmt_api.column_count
    end
    
    #
    # return the raw sql that was originally used to prepare the statement
    #
    def sql
      @stmt_api.sql
    end

    #
    # Close the statement.  The statement is no longer valid for use after it
    # has been closed.
    #
    def close
      @stmt_api.close
    end
  end
end
