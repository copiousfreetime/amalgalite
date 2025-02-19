#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

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
    SQL_TO_METHOD = {
      'date'      => 'date',
      'datetime'  => 'datetime',
      'timestamp' => 'time',
      'time'      => 'time',

      'double'    => 'float',
      'float'     => 'float',
      'real'      => 'float',
      'numeric'   => 'float',
      'decimal'   => 'float',

      'integer'   => 'integer',
      'tinyint'   => 'integer',
      'smallint'  => 'integer',
      'int'       => 'integer',
      'int2'      => 'integer',
      'int4'      => 'integer',
      'int8'      => 'integer',
      'bigint'    => 'integer',
      'serial'    => 'integer',
      'bigserial' => 'integer',

      'text'      => 'string',
      'char'      => 'string',
      'string'    => 'string',
      'varchar'   => 'string',
      'character' => 'string',
      'json'      => 'string',

      'bool'      => 'boolean',
      'boolean'   => 'boolean',

      'blob'      => 'blob',
      'binary'    => 'blob',
    }

    ##
    # A straight logical mapping (for me at least) of basic Ruby classes to SQLite types, if
    # nothing can be found then default to TEXT.
    #
    def bind_type_of( obj )
      case obj
      when Float
        ::Amalgalite::SQLite3::Constants::DataType::FLOAT
      when Integer
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
    def result_value_of( normalized_declared_type, value )
      case value
      when Numeric, NilClass, Amalgalite::Blob
        return value
      when String
        if normalized_declared_type then
          conversion_method = DefaultMap::SQL_TO_METHOD[normalized_declared_type]
          if conversion_method then
            return send(conversion_method, value)
          else
            raise ::Amalgalite::Error, "Unable to convert SQL type of #{normalized_declared_type} to a Ruby class"
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
    # convert a string to a datetime, if no timzone is found in the parsed
    # string, set it to the local offset.  
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
    # convert a string to a blob
    #
    def blob( str )
      ::Amalgalite::Blob.new( :string => str )
    end
  end
end
