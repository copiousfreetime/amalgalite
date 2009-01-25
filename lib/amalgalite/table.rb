#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

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

    def initialize( name, sql ) 
      @name    = name
      @sql     = sql
      @indexes = {}
      @columns = {}
    end

    # the Columns in original definition order
    def columns_in_order
      @columns.values.sort_by { |c| c.order }
    end

    # the column names in original definition order
    def column_names
      columns_in_order.map { |c| c.name }
    end
  end
end

