#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
#
require 'amalgalite/type_map'
require 'amalgalite3'

module Amalgalite::TypeMaps
  ##
  # An Amalagliate TypeMap that converts both bind parameters and result
  # parameters to a String, no matter what.
  #
  class TextMap < ::Amalgalite::TypeMap
    def bind_type_of( obj )
      return ::Amalgalite::SQLite3::Constants::DataType::TEXT
    end

    def result_value_of( delcared_type, value )
      return value.to_s
    end
  end
end
