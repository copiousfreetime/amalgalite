#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'amalgalite/table'
require 'amalgalite/index'
require 'amalgalite/column'
require 'amalgalite/view'

module Amalgalite

  class LazySchema< ::Hash
    attr_accessor :schema
    attr_accessor :load_method

    def []( name )
      t = nil
      if schema then
        t = fetch( name, nil )
        unless t
          t = schema.send( load_method, name )
          store( name, t )
        end
      end
      return t
    end
  end
  #
  # An object view of the schema  in the SQLite database.  If the schema changes
  # after this class is created, it has no knowledge of that.
  #
  class Schema

    attr_reader :catalog
    attr_reader :schema 
    attr_reader :tables
    attr_reader :views
    attr_reader :db

    #
    # Create a new instance of Schema
    #
    def initialize( db, catalog = 'main', schema = 'sqlite')
      @db = db
      @catalog = catalog
      @schema = schema
      @tables = LazySchema.new
      @tables.schema = self
      @tables.load_method = :load_table
      @views  = LazySchema.new
      @views.schema = self
      @views.load_method = :load_view
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
      @db.execute("SELECT tbl_name FROM sqlite_master WHERE type = 'table'") do |table_info|
        table = load_table( table_info['tbl_name'] )
        @tables[table.name] = table
      end

      @tables
    end

    ##
    # Load a single table
    def load_table( table_name )
      rows = @db.execute("SELECT tbl_name, sql FROM sqlite_master WHERE type = 'table' AND tbl_name = ?", table_name)
      table_info = rows.first
      table = nil
      if table_info then 
        table = Amalgalite::Table.new( table_info['tbl_name'], table_info['sql'] )
        table.columns = load_columns( table )
        table.schema = self
        table.indexes = load_indexes( table )
      end
      return table
    end

    ## 
    # load all the indexes for a particular table
    #
    def load_indexes( table )
      indexes = {}

      @db.prepare("SELECT name, sql FROM sqlite_master WHERE type ='index' and tbl_name = $name") do |idx_stmt|
        idx_stmt.execute( "$name" => table.name) do |idx_info|
          indexes[idx_info['name']] = Amalgalite::Index.new( idx_info['name'], idx_info['sql'], table )
        end
      end

      @db.execute("PRAGMA index_list( #{@db.quote(table.name)} );") do |idx_list|
        idx = indexes[idx_list['name']]
        
        idx.sequence_number = idx_list['seq']
        idx.unique          = Boolean.to_bool( idx_list['unique'] )

        @db.execute("PRAGMA index_info( #{@db.quote(idx.name)} );") do |col_info|
          idx.columns << table.columns[col_info['name']]
        end
      end
      return indexes
    end

    ##
    # load all the columns for a particular table
    #
    def load_columns( table )
      cols = {}
      idx = 0
      @db.execute("PRAGMA table_info(#{@db.quote(table.name)})") do |row|
        col = Amalgalite::Column.new( "main", table.name, row['name'], row['cid'])

        col.default_value = row['dflt_value']
        @db.api.table_column_metadata( "main", table.name, col.name ).each_pair do |key, value|
          col.send("#{key}=", value)
        end
        col.schema = self
        cols[col.name] = col
        idx += 1
      end
      cols
    end

    ##
    # load a single view
    #
    def load_view( name )
      rows = @db.execute("SELECT name, sql FROM sqlite_master WHERE type = 'view' AND name = ?", name )
      view_info = rows.first
      view = Amalgalite::View.new( view_info['name'], view_info['sql'] )
      view.schema = self
      return view
    end

    ##
    # load all the views for the database
    #
    def load_views
      @views = {}
      @db.execute("SELECT name, sql FROM sqlite_master WHERE type = 'view'") do |view_info|
        view = load_view( view_info['name'] )
        @views[view.name] = view
      end
      @views
    end
  end
end
