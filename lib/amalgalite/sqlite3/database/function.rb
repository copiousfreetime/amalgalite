module Amalgalite::SQLite3
  class Database
    ##
    # A wrapper around a Proc and a name for use in user defined  for use 
    class Function

      attr_reader :name

      def initialize( name, _proc )
        @name = name
        @function = _proc
      end

      def arity
        @function.arity
      end

      def call( *args )
        @function.call( args )
      end
    end
  end
end
