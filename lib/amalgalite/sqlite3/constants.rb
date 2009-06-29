#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
module Amalgalite::SQLite3
  module Constants
    module Helpers
      #
      # convert an integer value into the string representation of the associated
      # constant. this is a helper method used by some of the other modules
      #
      def name_from_value( value )
        unless defined? @const_map_from_value
          @const_map_from_value = {}
          constants.each do |const_name|
            c_int = const_get( const_name )
            @const_map_from_value[c_int] = const_name
          end
        end
        return @const_map_from_value[ value ]
      end

      #
      # convert a string into the constant value.  This is helper method used by
      # some of the other modules
      #
      def value_from_name( name )
        unless defined? @const_map_from_name
          @const_map_from_name = {}
          constants.each do |const_name|
            c_int = const_get( const_name )
            @const_map_from_name[ const_name ] = c_int
          end
        end
        return @const_map_from_name[ name.upcase ]
      end
    end


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
    # Status defines the namespace for all the possible status flags for
    # Amalgalite::SQLite3::Status objects
    #
    module Status
      extend Helpers
    end


    ##
    # DBStatus defines the namespace for all the possible status codes for the
    # Amalgalite::SQlite3::Database::Status objects.
    #
    module DBStatus
      extend Helpers
    end

    ##
    # ResultCode defines the namespace for all possible result codes from an
    # SQLite API call.
    #
    module ResultCode
      extend Helpers
    end # end ResultCode
  end
end
