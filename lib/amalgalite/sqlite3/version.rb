#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite/amalgalite3'
module Amalgalite 
  module SQLite3
    module Version
      # Sqlite3 version number is equal to 
      # MAJOR * 1_000_000 + MINOR * 1_000 + RELEASE

      # major version number of the SQLite C library
      MAJOR   = (to_i / 1_000_000).freeze
      
      # minor version number of the SQLite C library
      MINOR   = ((to_i % 1_000_000) / 1_000).freeze
      
      # release version number of the SQLite C library
      RELEASE = (to_i % 1_000).freeze
   
      #
      # call-seq:
      #   Amalgalite::SQLite3::Version.to_a -> [ MAJOR, MINOR, RELEASE ]
      #
      # Return the SQLite C library version number as an array of MAJOR, MINOR,
      # RELEASE
      # 
      def self.to_a
        [ MAJOR, MINOR, RELEASE ]
      end

    end

    # Version of SQLite that ships with Amalgalite
    VERSION = Version.to_s.freeze
  end
  Version.freeze
end
