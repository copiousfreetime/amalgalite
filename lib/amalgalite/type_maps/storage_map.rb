#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite::TypeMaps
  ##
  # An Amalagliate TypeMap that has a one-to-one conversion between SQLite types
  # and Ruby classes
  #
  class StorageMap < ::Amalgalite::TypeMap
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
    # Do no mapping, just return the value as it was retrieved from SQLite.
    #
    def result_value_of( delcared_type, value )
      return value
    end
  end
end
