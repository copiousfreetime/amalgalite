#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/table'
require 'amalgalite/index'
require 'amalgalite/column'
require 'amalgalite/view'

module Amalgalite
  #
  # An object view of the schema  in the SQLite database.  If the schema changes
  # after this class is created, it has no knowledge of that.
  #
  class Schema

    attr_reader :catalog
    attr_reader :schema 
    attr_reader :tables
    attr_reader :views

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
        table = Amalgalite::Table.new( table_info['tbl_name'], table_info['sql'] )
        table.columns = load_columns( table )

        @db.prepare("SELECT name, sql FROM sqlite_master WHERE type ='index' and tbl_name = @name") do |idx_stmt|
          idx_stmt.execute( "@name" => table.name) do |idx_info|
            table.indexes << Amalgalite::Index.new( idx_info['name'], idx_info['sql'], table )
          end
        end
        @tables[table.name] = table
      end

      @tables
    end

    ##
    # load all the columns for a particular table
    #
    def load_columns( table )
      cols = {}
      @db.execute("PRAGMA table_info(#{table.name})") do |row|
        col = Amalgalite::Column.new( row['name'], table )

        col.default_value = row['dflt_value']
        @db.api.column_metadata( table.name, col.name ).each_pair do |key, value|
          col.send("#{key}=", value)
        end
        cols[col.name] = col
      end
      cols
    end

    ##
    # load all the views for the database
    #
    def load_views
      @views = {}
      @db.execute("SELECT name, sql FROM sqlite_master WHERE type = 'view'") do |view_info|
        view = Amalgalite::View.new( view_info['name'], view_info['sql'] )
        @views[view.name] = view
      end
      @views
    end
  end
end
