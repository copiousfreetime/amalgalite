#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  # 
  # A ProfileSampler is a sampler of profile times.  It aggregates up profile
  # events that happen for the same source.  It is based upon the RFuzz::Sampler class 
  #
  class ProfileSampler
    def initialize( name )
      @name = name
      reset!
    end

    ##
    # reset the internal state so it may be used again
    def reset!
      @sum   = 0.0
      @sumsq = 0.0
      @n     = 0
      @min   = 0.0
      @max   = 0.0
    end

    ##
    # add a sample to the calculations
    #
    def sample( value )
      @sum   += value
      @sumsq += (value * value)
      if @n == 0 then
        @min = @max = value
      else
        @min = value if value < @min
        @max = value if value > @max
      end
      @n += 1
    end

    # return the mean of the data 
    def mean
      @sum / @n
    end

    # returns the standard deviation of the data
    def stddev
      begin
        Math.sqrt( (@sumsq - ( @sum * @sum / @n)) / (@n-1) )
      rescue Errno::EDOM
        return 0.0
      end
    end

    ##
    # return all the values as an array
    #
    def to_a
      [ @name, @sum, @sumsq, @n, mean, stddev, @min, @max ]
    end

    ##
    # return all the avlues as a hash
    #
    def to_h
      { 'name'    => @name,  'n' => @n,
        'sum'     => @sum,   'sumsq'   => @sumsq, 'mean'    => mean,
        'stddev'  => stddev, 'min'     => @min,   'max'     => @max }
    end

    ##
    # return a string containing the sampler summary
    #
    def to_s
      "[%s] => sum: %d, sumsq: %d, n: %d, mean: %0.6f, stddev: %0.6f, min: %d, max: %d" % to_a
    end

  end

  #
  # A Profile Tap recives +profile+ events which involve the number of
  # nanoseconds in wall-clock time it took for a particular thing to happen. In
  # general this is an SQL statement.
  #
  # It has a well known +profile+ method which when invoked will write the event
  # to a delegate object.
  #
  #
  class ProfileTap

    attr_reader :samplers

    def initialize( wrapped_obj, send_to = 'profile' )
      unless wrapped_obj.respond_to?( send_to ) 
        raise Amalgalite::Error, "#{wrapped_obj.class.name} does not respond to #{send_to.to_s} "
      end

      @delegate_obj    = wrapped_obj
      @delegate_method = send_to
      @samplers        = {}
    end

    def profile( msg, time )
      unless sampler = @samplers[msg] 
        msg = msg.gsub(/\s+/,' ')
        sampler = @samplers[msg] = ProfileSampler.new( msg )
      end
      sampler.sample( time )
      @delegate_obj.send( @delegate_method, msg, time )
    end
  end
end
