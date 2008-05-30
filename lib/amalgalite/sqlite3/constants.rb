#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite3'
module Amalgalite::SQLite3::Constants
  ##
  # DataType defines the namespace for all possible SQLite data types.
  # 
  module DataType
  end
  DataType.freeze

  ##
  # Open defines the namespace for all possible flags to the Database.open
  # method
  #
  module Open
  end
  Open.freeze

  ##
  # ResultCode defines the namespace for all possible result codes from an
  # SQLite API call.
  #
  module ResultCode
    #
    # convert an integer value into the string representation of the associated
    # ResultCode constant.
    #
    def self.from_int( value )
      unless @const_map_from_int
        @const_map_from_int = {}
        constants.each do |const_name|
          c_int = const_get( const_name )
          @const_map_from_int[c_int] = const_name
        end
      end
      return @const_map_from_int[ value ]
    end
  end # end ResultCode
end
