#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/boolean'
require 'amalgalite/blob'

module Amalgalite
  #
  # a class representing the meta information about an SQLite column, this class
  # serves both for general Schema level information, and for more common result
  # set information from a SELECT statemen.
  #
  class Column
    # the database this column belongs to
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
    def initialize( db, name, table )
      @db                 = db
      @name               = name
      @table              = table
      @declared_data_type = nil
      @default_value      = nil
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

    def ruby_type_label
      unless @ruby_type_label
        if declared_data_type.nil? or declared_data_type.length == 0 then
          @ruby_type_label = :unknown # so it is a non-null value but isn't a real conversion type
        else
          @ruby_type_label = Type.sql_to_ruby( declared_data_type.downcase )
        end
      end
      return @ruby_type_label
    end

    #
    # Do a mashup of type conversion.  There is the storage class from  SQLite
    # and then there is the declared type of the column that the result is
    # coming from. 
    #
    # We'll try and use the declared type of the column, and if there isn't one,
    # fallback to the storage klass that sqlite told us about
    #
    def convert_type( storage_class )
      return :nil if SQLite3::Constants::DataType::NULL == storage_class

      type_label = nil
      if ruby_type_label == :unknown then
        case storage_class
        when SQLite3::Constants::DataType::INTEGER
          type_label = :integer
        when SQLite3::Constants::DataType::FLOAT
          type_label = :float
        when SQLite3::Constants::DataType::TEXT
          type_label = :string
        when SQLite3::Constants::DataType::BLOB
          type_label = :blob 
        else
          raise ::Amalgalite::Error, "Unknown sqlite storage class of #{storage_class}"
        end
      else
        type_label = ruby_type_label
      end
     
      return type_label
    end

    # 
    # Type conversion between SQL types and ruby types.
    #
    class Type

      class << self

        def ruby_to_sql 
          @ruby_to_sql ||= {
              :date      => %w[ date ],
              :datetime  => %w[ datetime ],
              :time      => %w[ timestamp ],
              :float     => %w[ double real numeric decimal ],
              :integer   => %w[ integer tinyint smallint int int2 int4 int8 bigint serial bigserial ],
              :string    => %w[ text char varchar character ],
              :boolean   => %w[ bool boolean ],
              :blob      => %w[ binary blob ],
            }
        end

        def sql_to_ruby( sql_type )
          unless @sql_to_ruby
            @sql_to_ruby = {}
            ruby_to_sql.each_pair do |type_label, types|
              types.each { |t| @sql_to_ruby[t] = type_label }
            end
          end
          return @sql_to_ruby[sql_type]
        end
      end
    end # end Type

  end
end
