#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/table'
require 'amalgalite/index'

module Amalgalite
  #
  # An object view of the schema  in the SQLite database.  If the schema changes
  # after this class is created, it has no knowledge of that.
  #
  class Schema

    attr_reader :catalog
    attr_reader :schema 

    def initialize( db, catalog = 'main', schema = 'sqlite')
      @db = db
      @catalog = catalog
      @schema = schema

      load_schema!
    end

    #
    # load the schema from the database
    def load_schema!
      load_tables
      load_views
    end

    ##
    # load all the tables
    #
    def load_tables
      @tables = {}
      @db.execute("SELECT tbl_name, sql FROM sqlite_master WHERE type = 'table'") do |table_info|
        table = Amalgalite::Table.new( table_info['name'], table_info['sql'] )
        table.columns = @db.pragma "table_info( #{table.name })"

        @db.execute("SELECT name, sql FROM sqlite_master WHERE type ='index' and tbl_name = @name") do |idx_info|
          table.indexes << Amalgalite::Index.new( idx_info['name'], idx_info['sql'], table )
        end
        @tables[table.name] = table
      end
      @tables
    end
  end
end
