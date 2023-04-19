#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
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

      def self.compiled_matches_runtime?
        self.compiled_version == self.runtime_version
      end
    end

    # Version of SQLite that ships with Amalgalite
    VERSION = Version.to_s.freeze
  end
end

unless Amalgalite::SQLite3::Version.compiled_matches_runtime? then
  warn <<eom
You are seeing something odd.  The compiled version of SQLite that
is embedded in this extension is for some reason, not being used.
The version in the extension is #{Amalgalite::SQLite3::Version.compiled_version} and the version that
as been loaded as a shared library is #{Amalgalite::SQLite3::Version.runtime_version}.  These versions
should be the same, but they are not.

One known issue is if you are using this libary in conjunction with
Hitimes on Mac OS X.  You should make sure that "require 'amalgalite'"
appears before "require 'hitimes'" in your ruby code.

This is a non-trivial problem, and I am working on it.
eom
end
