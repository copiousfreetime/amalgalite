#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/type_map'
require 'amalgalite3'
require 'time'
require 'date'

module Amalgalite::TypeMaps
  ##
  # An Amalgalite::TypeMap that does its best to convert between Ruby classes
  # and known SQL data types.  
  #
  # Upon instantiation, DefaultMap generates a conversion map to try to figure
  # out the best way to convert between populate SQL 'types' and ruby classes
  #
  class DefaultMap
    class << self
      def methods_handling_sql_types # :nodoc:
        @methods_handling_sql_types ||= {
          'date'      => %w[ date ],
          'datetime'  => %w[ datetime ],
          'time'      => %w[ timestamp ],
          'float'     => %w[ double real numeric decimal ],
          'integer'   => %w[ integer tinyint smallint int int2 int4 int8 bigint serial bigserial ],
          'string'    => %w[ text char varchar character ],
          'boolean'   => %w[ bool boolean ],
          'blob'      => %w[ binary blob ],
        }
      end

      # say what method to call to convert an sql type to a ruby type
      #
      def sql_to_method( sql_type  ) # :nodoc:
        unless @sql_to_method
          @sql_to_method = {}
          methods_handling_sql_types.each_pair do |method, sql_types|
            sql_types.each { |t| @sql_to_method[t] = method }
          end
        end
        return_method = @sql_to_method[sql_type]

        # the straight lookup didn't work, try iterating through the types and
        # see what is found
        unless return_method
          @sql_to_method.each_pair do |sql, method|
            if sql_type.index(sql) then
              return_method = method
              break
            end
          end
        end
        return return_method
      end
    end

    def initialize
    end

    ##
    # A straight logical mapping (for me at least) of basic Ruby classes to SQLite types, if
    # nothing can be found then default to TEXT.
    #
    def bind_type_of( obj )
      case obj
      when Float
        ::Amalgalite::SQLite3::Constants::DataType::FLOAT
      when Fixnum
        ::Amalgalite::SQLite3::Constants::DataType::INTEGER
      when NilClass
        ::Amalgalite::SQLite3::Constants::DataType::NULL
      when ::Amalgalite::Blob
        ::Amalgalite::SQLite3::Constants::DataType::BLOB
      else
        ::Amalgalite::SQLite3::Constants::DataType::TEXT
      end
    end

    ##
    # Map the incoming value to an outgoing value.  For some incoming values,
    # there will be no change, but for some (i.e. Dates and Times) there is some
    # conversion
    #
    def result_value_of( declared_type, value )
      case value
      when Numeric
        return value
      when NilClass
        return value
      when String
        if declared_type then
          conversion_method = DefaultMap.sql_to_method( declared_type.downcase )
          if conversion_method then
            return send(conversion_method, value)  
          else
            raise ::Amalgalite::Error, "Unable to convert SQL type of #{declared_type} to a Ruby class"
          end
        else
          # unable to do any other conversion, just return what we have.
          return value
        end
      else 
        raise ::Amalgalite::Error, "Unable to convert a class #{value.class.name} with value #{value.inspect}"
      end
    end

    ##
    # convert a string to a date
    #
    def date( str )
      Date.parse( str )
    end

    ##
    # convert a string to a datetime
    #
    def datetime( str )
      DateTime.parse( str )
    end

    ##
    # convert a string to a Time
    #
    def time( str )
      Time.parse( str )
    end

    ##
    # convert a string to a Float
    #
    def float( str )
      Float( str )
    end

    ##
    # convert an string to an Integer
    #
    def integer( str )
      Float( str ).to_i
    end

    ##
    # convert a string to a String, yes redundant I know.
    # 
    def string( str )
      str
    end

    ##
    # convert a string to true of false
    #
    def boolean( str )
      ::Amalgalite::Boolean.to_bool( str )
    end

    ##
    # convert a string to a blog
    #
    def blob( str )
      raise NotImplementedError, "Blob type conversion is not implemented"
    end
  end
end
