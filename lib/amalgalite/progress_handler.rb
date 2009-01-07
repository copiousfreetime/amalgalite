module Amalgalite
  ##
  # A base class for use in creating your own progress handler classes
  #
  class ProgressHandler
    def to_proc
      self
    end

    # the arity of the call method
    def arity() 0 ; end

    ##
    # Override this method, returning +false+ if the SQLite should act as if
    # +interrupt!+ had been invoked.
    # 
    def call
      raise NotImplementedError, "The progress handler call() method must be implemented"
    end
  end
end
