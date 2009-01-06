require 'amalgalite/sqlite3/database/function'
module Amalgalite
  #
  # A Base class to inherit from for creating your own SQL scalar unctions in ruby.
  #
  # These are SQL functions similar to _abs(X)_, _length(X)_, _random()_.  Items
  # that take parameters and return value.  They have no state between calls.
  #
  # Functions defined in Amalgalite databases conform to the Proc interface.
  # Everything that is defined in an Amalgalite database using +define_function+
  # has its +to_proc+ method called.  As a result, any Function must also
  # conform to the +to_proc+ protocol.
  #
  # If you choose to use Function as a parent class of your SQL scalar function
  # implementation you should only have implement +call+ with the appropriate
  # _arity_.
  #
  # For instance to implement a _sha1(X)_ SQL function you could implement it as
  #
  #   class SQLSha1 < ::Amalgalite::Function
  #     def initialize
  #       super( 'md5', 1 )
  #     end
  #     def call( s )
  #       ::Digest::MD5.hexdigest( s.to_s )
  #     end
  #   end
  #
  class Function
    # The name of the SQL function
    attr_accessor :name

    # The arity of the SQL function
    attr_accessor :arity

    # Initialize the function with a name and arity
    def initialize( name, arity )
      @name = name
      @arity = arity
    end

    # All SQL functions defined foloow the +to_proc+ protocol
    def to_proc
      self
    end

    # <b>Do Not Override</b>
    #
    # The function signature for use by the Amaglaite datase in tracking
    # function creation.
    #
    def signature
      @signature ||= ::Amalgalite::SQLite3::Database::Function.signature( self.name, self.arity )
    end
  end
end
