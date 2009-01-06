module Amalgalite::SQLite3
  class Database
    ##
    # A wrapper around a proc for use as an SQLite Ddatabase fuction
    #
    #   f = Function.new( 'md5', lambda { |x| Digest::MD5.hexdigest( x.to_s ) } )
    #
    class Function

      # the name of the function, and how it will be called in SQL
      attr_reader :name

      # The unique signature of this function.  This is used to determin if the
      # function is already registered or not
      #
      def self.signature( name, arity )
        "#{name}/#{arity}"
      end

      # Initialize with the name and the Proc
      #
      def initialize( name, _proc )
        @name = name
        @function = _proc
      end

      # The unique signature of this function
      #
      def signature
        @signature ||= Function.signature( name, arity )
      end
      alias :to_s :signature

      # The arity of SQL function, -1 means it is takes a variable number of
      # arguments.
      #
      def arity
        @function.arity
      end

      # Invoke the proc 
      #
      def call( *args )
        @function.call( *args )
      end
    end
  end
end
