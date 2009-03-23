#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'set'
module Amalgalite
  #
  # a class representing the meta information about an SQLite table 
  #
  class Table
    # the schema object the table is associated with
    attr_accessor :schema

    # the table name
    attr_reader   :name

    # the original sql that was used to create this table
    attr_reader   :sql

    # hash of Index objects holding the meta informationa about the indexes
    # on this table.  The keys of the indexes variable is the index name
    attr_accessor :indexes

    # a hash of Column objects holding the meta information about the columns
    # in this table.  keys are the column names
    attr_accessor :columns

    def initialize( name, sql = nil ) 
      @name    = name
      @sql     = sql
      @indexes = {}
      @columns = {}
    end

    # Is the table a temporary table or not
    def temporary?
      !sql
    end


    # the Columns in original definition order
    def columns_in_order
      @columns.values.sort_by { |c| c.order }
    end

    # the column names in original definition order
    def column_names
      columns_in_order.map { |c| c.name }
    end

    # the columns that make up the primary key
    def primary_key_columns
      @columns.values.find_all { |c| c.primary_key? }
    end

    # the array of colmuns that make up the primary key of the table
    # since a primary key has an index, we loop over all the indexes for the
    # table and pick the first one that is unique, and all the columns in the
    # index have primary_key? as true.
    #
    # we do this instead of just looking for the columns where primary key is
    # true because we want the columns in primary key order
    def primary_key
      @primary_key ||= (
        pk_column_names = Set.new( primary_key_columns.collect { |c| c.name } )
        unique_indexes  = indexes.values.find_all { |i| i.unique? }
        pk_columns = []
        unique_indexes.each do |idx|
          idx_column_names = Set.new( idx.columns.collect { |c| c.name } )
          r = idx_column_names ^ pk_column_names
          if r.size == 0
            pk_columns = idx.columns
            break
          end
        end
        pk_columns
      )
    end
  end
end

