require 'amalgalite3'
require 'amalgalite/sqlite3/constants'
module Amalgalite::SQLite3
  class Database
    # 
    # A Stat represents a single Database Status code and its current highwater mark.
    #
    # Some stats may not have a current or a highwater value, in those cases
    # the associated _has_current?_ or _has_highwater?_ method returns false and the
    # _current_ or _highwater_ method also returns +nil+.
    #
    class Stat
      attr_reader :name
      attr_reader :code

      def initialize( api_db, name )
        @name      = name
        @code      = ::Amalgalite::SQLite3::Constants::DBStatus.value_from_name( name )
        @current   = nil
        @highwater = nil
        @api_db    = api_db 
      end

      def current
        update!
        return @current
      end

      def highwater
        update!
        return @highwater
      end

      #
      # reset the given stat's highwater mark.  This will also populate the
      # _@current_ and _@highwater_ instance variables
      #
      def reset!
        update!( true )
      end
    end

    #
    # Top level Status object holding all the Stat objects indicating the DBStatus
    # of the SQLite3 C library.
    #
    class DBStatus
      ::Amalgalite::SQLite3::Constants::DBStatus.constants.each do |const_name|
        method_name = const_name.downcase
        module_eval( <<-code, __FILE__, __LINE__ )
        def #{method_name}
          @#{method_name} ||=  Amalgalite::SQLite3::Database::Stat.new( self.api_db, '#{method_name}' )   
        end
      code
      end

      attr_reader :api_db

      def initialize( api_db )
        @api_db = api_db
      end
    end

    # return the DBstatus object for the sqlite database
    def status
      @status ||= DBStatus.new( self )
    end
  end
end
