#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for licensingn details
#++

module Amalgalite
  # Version information for Amagalite
  module Version

    MAJOR   = 0
    MINOR   = 2
    BUILD   = 4

    #
    # return the Version as an array of MAJOR, MINOR, BUILD
    #
    def self.to_a 
      [MAJOR, MINOR, BUILD]
    end

    # return the Version as a dotted String MAJOR.MINOR.BUILD
    def self.to_s
      to_a.join(".")
    end

    # Version string constant
    STRING = Version.to_s.freeze
  end

  # Version string constant
  VERSION = Version.to_s.freeze
end 
