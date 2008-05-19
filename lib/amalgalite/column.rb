#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  #
  # a class representing the meta information about an SQLite column
  #
  class Column

    # the column name
    attr_accessor :name

    # the table to which this column belongs
    attr_accessor :table

    # the default value of the column.  Nil here means that there is no default
    # value
    attr_accessor :default_value

    # the declared data type of the column in the original sql
    attr_accessor :declared_data_type
    
    # the collation sequence name of the column
    attr_accessor :collation_sequence_name

    # true if the column has a NOT NULL constraint, false otherwise
    attr_accessor :not_null_constraint

    # true if the column is part of a primary key, false otherwise
    attr_accessor :primary_key

    # true if the column is AUTO INCREMENT, false otherwise
    attr_accessor :auto_increment

    # 
    # Create a column with its name and associated table
    #
    def initialize( name, table )
      @name = name
      @table = table
    end

    def has_default_value?
      not default_value.nil?
    end

    def nullable?
      not_null_constraint == false
    end

    def not_null_constraint?
      not_null_constraint
    end

    def primary_key?
      primary_key
    end

    def auto_increment?
      auto_increment
    end
  end
end
