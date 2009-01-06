require 'amalgalite/sqlite3/database/function'
module Amalgalite
  #
  # A Base class to inherit from for creating your own SQL aggregate functions
  # in ruby.
  #
  # These are SQL functions similar to _max(X)_, _count(X)_, _avg(X)_. The built
  # in SQLite aggregate functions are:
  #
  # * http://www.sqlite.org/lang_aggfunc.html
  #
  # If you choose to use Aggregate as a parent class of your SQL scalar function
  # implementation you must:
  #
  # * implement _initalize()_ with 0 arguments
  # * set the @arity data member
  # * set the @name data member 
  # * implement _step_ with arity of +@arity+
  # * implement _finalize_ with arity of 0
  #
  # For instance to implement a _unique_word_count(X)_ aggregate function you could
  # implement it as:
  #
  #   class UniqueWordCount < ::Amalgalite::Aggregate
  #     attr_accessor :words
  #
  #     def initialize
  #       @name = 'unique_word_count'
  #       @arity = 1
  #       @words = Hash.new { |h,k| h[k] = 0 }
  #     end
  #
  #     def step( str )
  #       str.split(/\W+/).each do |word|
  #         words[ word.downcase ] += 1
  #       end
  #       return nil
  #     end
  #
  #     def finalize
  #       return words.size
  #     end
  #   end
  #
  #
  class Aggregate
    # The name of the SQL function
    attr_accessor :name

    # The arity of the SQL function
    attr_accessor :arity

    # finalize should return the final value of the aggregate function
    def finalize
      raise NotImplementedError, "Aggregate#finalize must be implemented"
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
