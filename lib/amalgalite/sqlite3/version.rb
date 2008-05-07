#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
module Amalgalite 
  module SQLite3
    module Version

      # Sqlite3 version number is equal to 
      # MAJOR * 1_000_000 + MINOR * 1_000 + RELEASE
      MAJOR   = to_i / 1_000_000
      MINOR   = (to_i % 1_000_000) / 1_000
      RELEASE = (to_i % 1_000)
    
      def to_a
        [ MAJOR, MINOR, RELEASE ]
      end
      module_function :to_a

    end
    VERSION = Version.to_s
  end
end
