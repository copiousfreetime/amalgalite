module Amalgalite::SQLite3
  class Database
    ##
    # A wrapper around a Proc and a name for use in user defined  for use 
    class Function

      attr_reader :name
      def self.signature( name, arity )
        "#{name}/#{arity}"
      end

      def initialize( name, _proc )
        @name = name
        @function = _proc
      end

      def signature
        @signature ||= Function.signature( name, arity )
      end

      def arity
        @function.arity
      end

      def call( *args )
        @function.call( *args )
      end

      def to_s
        signature
      end
    end
  end
end
