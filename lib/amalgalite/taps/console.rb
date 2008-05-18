#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/taps/io'

module Amalgalite::Taps
  #
  # Class provide an IO tap that can write to $stdout
  #
  class Stdout < ::Amalgalite::Taps::IO
    def initialize
      super( $stdout )
    end
  end

  #
  # This class provide an IO tap that can write to $stderr
  #
  class Stderr < ::Amalgalite::Taps::IO
    def initialize
      super( $stderr )
    end
  end

end
