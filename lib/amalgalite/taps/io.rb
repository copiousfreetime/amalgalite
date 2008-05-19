#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/profile_tap'
require 'stringio'

module Amalgalite
  module Taps
    #
    # An IOTap to make it easy to send tap all tap  information to any IO based
    # object.  Both profile and trace tap information can be captured
    # This means you can do:
    #
    #   db.profile_tap = db.trace_tap  = Amalgalite::Taps::Stdout.new
    #
    # of if you want to separa
    #
    class IO

      attr_reader :profile_tap
      attr_reader :io

      def initialize( io )
        @io = io
        @profile_tap = ProfileTap.new( self, 'output_profile_event' )
      end

      def trace( msg )
        io.puts msg 
      end

      # need a profile method, it routes through the profile tap which calls back
      # to output_profile_event
      def profile( msg, time )
        @profile_tap.profile(msg, time)
      end

      def output_profile_event( msg, time )
        io.puts "#{time} : #{msg}"
      end

      def dump_profile
        samplers.each do |s|
          io.puts s.to_s
        end
      end

      def samplers
        profile_tap.samplers
      end
    end

    #
    # This class provides an IO tap that writes to a StringIO.  The result is
    # available via .to_s or .string.
    #
    class StringIO < ::Amalgalite::Taps::IO
      def initialize
        @stringio = ::StringIO.new
        super( @stringio )
      end

      def to_s
        @stringio.string
      end
      alias :string :to_s
    end
  end
end

