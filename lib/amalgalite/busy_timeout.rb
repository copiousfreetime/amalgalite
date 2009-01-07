module Amalgalite
  ##
  # A base class for use in creating your own busy handler classes
  #
  class BusyHandler
    def to_proc
      self
    end

    # the arity of the call method
    def arity() 1 ; end

    ##
    # Override this method, returning +false+ if the SQLite should return
    # SQLITE_BUSY for all parties involved in the lock, and anything else if the
    # lock attempt should be tried again.
    def call( count )
      raise NotImplementedError, "The busy handler call(N) method must be implemented"
    end
  end

  ##
  # A busy time out class for use in Database#define_busy_handler
  #
  class BusyTimeout < BusyHandler
    attr_reader :call_count
    ##
    # intialize by setting _count_ and _duration_ ( in milliseconds ).
    #
    def initialize( count = 20 , duration = 50 )
      @count = count
      @duration = duration.to_f / 1_000
      @call_count = 0
    end

    ##
    # return +false+ if _callcount_ is >  _count_ otherwise sleep for _duration_
    # milliseconds and then return +true+
    #
    def call( call_count )
      @call_count = call_count
      return false if ( call_count > @count )
      sleep @duration
      return true
    end
  end
end
