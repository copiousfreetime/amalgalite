#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite3'
module Amalgalite::SQLite3::Constants::ResultCode
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
end
