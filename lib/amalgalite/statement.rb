#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
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
    end


    ##
    # reset the Statement back to it state right after the constructor returned,
    # AND clear all parameter bindings.
    #
    def reset_and_clear_bindings!
      reset!
      @stmt_api.clear_bindings!
    end


    #
    # Iterate over the results of the statement returning the results as a hash
    # by column name.
    #
    # TODO: return results as hash or arrayfields if setup to do so.
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
        raise Amalgalite::SQLite3::Error, "got rc of #{rc}"
      end
      return row
    end

    #
    # return an ordered array of the columns names as they are thought of for
    # this query.
    #
    def column_names
      unless @column_names
        names = []
        column_count.times do |idx|
          names << @stmt_api.column_name( idx )
        end
        @column_names = names
      end
      return @column_names
    end


    #
    # return the number of columns in the result of this query
    #
    def column_count
      @stmt_api.column_count
    end
     
    # return the sql for this statement
    def sql
      @stmt_api.sql
    end

    #
    # close the statement
    #
    def close
      @stmt_api.close
    end
  end
end

 
