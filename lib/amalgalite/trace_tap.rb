#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  #
  # A TraceTap is a wrapper around another object and a method.  The Tap object
  # will receive the call to +trace+ and redirect that call to another object
  # and method.
  #
  class TraceTap

    attr_reader :delegate_obj
    attr_reader :delegate_method

    def initialize( wrapped_obj, send_to = 'trace' )
      unless wrapped_obj.respond_to?( send_to ) 
        raise Amalgalite::Error, "#{wrapped_obj.class.name} does not respond to #{send_to.to_s} "
      end

      @delegate_obj = wrapped_obj
      @delegate_method = send_to
    end

    def trace( msg )
      delegate_obj.send( delegate_method, msg )
    end
  end
end

