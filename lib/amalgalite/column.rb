#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/boolean'
require 'amalgalite/blob'

module Amalgalite
  ##
  # a class representing the meta information about an SQLite column, this class
  # serves both for general Schema level information, and for result set
  # information from a SELECT query.
  #
  class Column
    # the schema object this column is associated with
    attr_accessor :schema

    # the database name this column belongs to
    attr_accessor :db

    # the column name
    attr_accessor :name

    # the table to which this column belongs
    attr_accessor :table

    # the default value of the column.   This may not have a value and that
    # either means that there is no default value, or one could not be
    # determined.
    #
    attr_accessor :default_value

    # the declared data type of the column in the original sql that created the
    # column
    attr_accessor :declared_data_type

    # the collation sequence name of the column
    attr_accessor :collation_sequence_name

    # true if the column has a NOT NULL constraint, false otherwise
    attr_accessor :not_null_constraint

    # true if the column is part of a primary key, false otherwise
    attr_accessor :primary_key

    # true if the column is AUTO INCREMENT, false otherwise
    attr_accessor :auto_increment

    # The index (starting with 0) of this column in the table definition
    # or result set
    attr_accessor :order

    ##
    # Create a column with its name and associated table
    #
    def initialize( db, table, name, order)
      @db                 = db
      @name               = name
      @table              = table
      @order              = Float(order).to_i
      @declared_data_type = nil
      @default_value      = nil
    end

    # true if the column has a default value
    def has_default_value?
      not default_value.nil?
    end

    # true if the column may have a NULL value
    def nullable?
      not_null_constraint == false
    end

    # true if the column as a NOT NULL constraint
    def not_null_constraint?
      not_null_constraint
    end

    # true if the column is a primary key column
    def primary_key?
      primary_key
    end

    # true if the column is auto increment
    def auto_increment?
      auto_increment
    end
  end
end
