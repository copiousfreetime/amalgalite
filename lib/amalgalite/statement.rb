#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
#
require 'date'
require 'amalgalite/result'

module Amalgalite
  class Statement

    include ::Amalgalite::SQLite3::Constants

    attr_reader :db
    attr_reader :api

    class << self
      # special column names that indicate that indicate the column is a rowid
      def rowid_column_names
        @rowid_column_names ||= %w[ ROWID OID _ROWID_ ]
      end
    end

    ##
    # Initialize a new statement on the database.  
    #
    def initialize( db, sql )
      @db = db
      #prepare_method   =  @db.utf16? ? :prepare16 : :prepare
      prepare_method   =  :prepare
      @param_positions = {}
      @stmt_api        = @db.api.send( prepare_method, sql )
      @blobs_to_write  = []
      @rowid_index     = nil
      @result_meta     = nil
      @open            = true
    end

    ##
    # is the statement open for business
    #
    def open?
      @open
    end

    ##
    # Is the special column "ROWID", "OID", or "_ROWID_" used?
    #
    def using_rowid_column?
      not @rowid_index.nil?
    end

    ##
    # reset the Statement back to it state right after the constructor returned,
    # except if any variables have been bound to parameters, those are still
    # bound.
    #
    def reset!
      @stmt_api.reset!
      @param_positions = {}
      @blobs_to_write.clear
      @rowid_index = nil
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
    # reset the statment in preparation for executing it again
    #
    def reset_for_next_execute!
      @stmt_api.reset!
      @stmt_api.clear_bindings!
      @blobs_to_write.clear
    end

    ##
    # Execute the statement with the given parameters
    #
    # If a block is given, then yield each returned row to the block.  If no
    # block is given then return all rows from the result.  No matter what the
    # prepared statement should be reset before returning the final time.
    #
    def execute( *params )
      bind( *params )
      begin
        # save the error state at the beginning of the execution.  We only want to
        # reraise the error if it was raised during this execution.
        s_before = $!
        if block_given? then
          while row = next_row
            yield row
          end
        else
          all_rows
        end
      ensure
        s = $!
        begin
          reset_for_next_execute!
        rescue
          # rescuing nothing on purpose
        end
        raise s if s != s_before
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
      if params.nil? or params.empty? then
        check_parameter_count!( 0 )
        return nil 
      end

      if params.first.instance_of?( Hash ) then
        bind_named_parameters( params.first )
      elsif params.first.instance_of?( Array ) then
        bind_positional_parameters( *params )
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
          raise Amalgalite::Error, "Unable to find parameter '#{param}' in SQL statement [#{sql}]"
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
      bind_type = db.type_map.bind_type_of( value ) 
      case bind_type
      when DataType::FLOAT
        @stmt_api.bind_double( position, value )
      when DataType::INTEGER
        @stmt_api.bind_int64( position, value )
      when DataType::NULL
        @stmt_api.bind_null( position )
      when DataType::TEXT
        @stmt_api.bind_text( position, value.to_s )
      when DataType::BLOB
        if value.incremental? then
          @stmt_api.bind_zeroblob( position, value.length )
          @blobs_to_write << value
        else
          @stmt_api.bind_blob( position, value.source )
        end
      else
        raise ::Amalgalite::Error, "Unknown binding type of #{bind_type} from #{db.type_map.class.name}.bind_type_of"
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

    ##
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

    ##
    # Write any blobs that have been bound to parameters to the database.  This
    # assumes that the blobs go into the last inserted row
    #
    def write_blobs
      unless @blobs_to_write.empty?
        @blobs_to_write.each do |blob|
          blob.write_to_column!
        end
      end
    end

    ##
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

    ##
    # Return the next row of data, with type conversion as indicated by the
    # Database#type_map
    #
    def next_row
      row = nil
      case rc = @stmt_api.step
      when ResultCode::ROW
        row = ::Amalgalite::Result::Row.new(field_map: result_field_map, values: Array.new(result_meta.size))
        result_meta.each.with_index do |col, idx|
          value = nil
          column_type = @stmt_api.column_type( idx )
          case column_type
          when DataType::TEXT
            value = @stmt_api.column_text( idx )
          when DataType::FLOAT
            value = @stmt_api.column_double( idx )
          when DataType::INTEGER
            value = @stmt_api.column_int64( idx )
          when DataType::NULL
            value = nil
          when DataType::BLOB
            # if the rowid column is encountered, then we can use an incremental
            # blob api, otherwise we have to use the all at once version.
            if using_rowid_column? then
              value = Amalgalite::Blob.new( :db_blob => SQLite3::Blob.new( db.api,
                                                                           col.db,
                                                                           col.table,
                                                                           col.name,
                                                                           @stmt_api.column_int64( @rowid_index ),
                                                                           "r"),
                                            :column => col)
            else
              value = Amalgalite::Blob.new( :string => @stmt_api.column_blob( idx ), :column => col )
            end
          else
            raise ::Amalgalite::Error, "BUG! : Unknown SQLite column type of #{column_type}"
          end

          row.store_by_index(idx, db.type_map.result_value_of( col.normalized_declared_data_type, value ))
        end
      when ResultCode::DONE
        write_blobs
      else
        self.close # must close so that the error message is guaranteed to be pushed into the database handler
                   # and we can call last_error_message on it
        msg = "SQLITE ERROR #{rc} (#{Amalgalite::SQLite3::Constants::ResultCode.name_from_value( rc )}) : #{@db.api.last_error_message}"
        raise Amalgalite::SQLite3::Error, msg
      end
      return row
    end

    ##
    # Return all rows from the statement as one array
    #
    def all_rows
      rows = []
      while row = next_row
        rows << row
      end
      return rows
    end

    ##
    # Inspect the statement and gather all the meta information about the
    # results, include the name of the column result column and the origin
    # column.  The origin column is the original database.table.column the value
    # comes from.
    #
    # The full meta information from the origin column is also obtained for help
    # in doing type conversion.
    #
    # As iteration over the row meta information happens, record if the special
    # "ROWID", "OID", or "_ROWID_" column is encountered.  If that column is
    # encountered then we make note of it.
    #
    # This method cannot be called until after the @stmt_api has returne from
    # `step` at least once
    #
    def result_meta
      unless @result_meta
        meta = []
        column_count.times do |idx|
          as_name  = @stmt_api.column_name( idx )
          db_name  = @stmt_api.column_database_name( idx )
          tbl_name = @stmt_api.column_table_name( idx )
          col_name = @stmt_api.column_origin_name( idx )

          column_meta = ::Amalgalite::Column.new( db_name, tbl_name, col_name, idx, as_name )
          column_meta.declared_data_type = @stmt_api.column_declared_type( idx )

          # only check for rowid if we have a table name and it is not one of the
          # sqlite_master tables.  We could get recursion in those cases.
          if not using_rowid_column? and tbl_name and
             not %w[ sqlite_master sqlite_temp_master ].include?( tbl_name ) and is_column_rowid?( tbl_name, col_name ) then
            @rowid_index = idx
          end

          meta << column_meta
        end

        @result_meta = meta
      end
      return @result_meta
    end

    ##
    # is the column indicated by the Column a 'rowid' column
    #
    def is_column_rowid?( table_name, column_name )
      table_schema = @db.schema.tables[table_name]
      return false unless table_schema

      column_schema  = table_schema.columns[column_name]
      if column_schema then
        if column_schema.primary_key? and column_schema.declared_data_type and column_schema.declared_data_type.upcase == "INTEGER" then
          return true
        end
      else
        return true if Statement.rowid_column_names.include?( column_name.upcase )
      end
      return false
    end

    ##
    # Return the array of field names for the result set, the field names are
    # all strings
    #
    def result_fields
      @fields ||= result_meta.collect { |m| m.as_name }
    end

    def result_field_map
      @result_field_map ||= {}.tap do |map|
        result_meta.each do |column|
          map[column.as_name.to_s] = column.order
          map[column.as_name.to_sym] = column.order
        end
      end
    end

    ##
    # Return any unsued SQL from the statement
    #
    def remaining_sql
      @stmt_api.remaining_sql
    end


    ##
    # return the number of columns in the result of this query
    #
    def column_count
      @stmt_api.column_count
    end

    ##
    # return the raw sql that was originally used to prepare the statement
    #
    def sql
      @stmt_api.sql
    end

    ##
    # Close the statement.  The statement is no longer valid for use after it
    # has been closed.
    #
    def close
      if open? then
        @stmt_api.close
        @open = false
      end
    end
  end
end
