require 'amalgalite/database'
module Amalgalite
  #
  # The encapsulation of a connection to an SQLite3 in-memory database.  
  #
  # Open an in-memory database:
  #
  #   db = Amalgalite::MemoryDatabase.new
  #
  class MemoryDatabase < Database
    def initialize
      super( ":memory:" )
    end
  end
end
