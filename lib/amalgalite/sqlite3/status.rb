require 'amalgalite/amalgalite3'
require 'amalgalite/sqlite3/constants'
module Amalgalite::SQLite3

  # 
  # A Stat represents a single Status code and its current highwater mark.
  #
  # Some stats may not have a current or a highwater value, in those cases
  # the associated _has_current?_ or _has_highwater?_ method returns false and the
  # _current_ or _highwater_ method also returns +nil+.
  #
  class Stat
    attr_reader :name
    attr_reader :code

    def initialize( name )
      @name      = name
      @code      = ::Amalgalite::SQLite3::Constants::Status.value_from_name( name )
      @current   = nil
      @highwater = nil
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
  # Top level Status object holding all the Stat objects indicating the Status
  # of the SQLite3 C library.
  #
  class Status
    ::Amalgalite::SQLite3::Constants::Status.constants.each do |const_name|
      method_name = const_name.downcase
      module_eval( <<-code, __FILE__, __LINE__ )
        def #{method_name}
          @#{method_name} ||=  Amalgalite::SQLite3::Stat.new( '#{method_name}' )   
        end
      code
    end
  end

  # return the status object for the sqlite database
  def self.status
    @status ||= Status.new
  end
end
