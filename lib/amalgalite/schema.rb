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

    # The internal database that this schema is for. Most of the time this will
    # be 'main' for the main database. For the temp tables, this will be 'temp'
    # and for any attached databsae, this is the name of attached database.
    attr_reader :catalog

    # The schema_version at the time this schema was taken.
    attr_reader :schema_version

    # The Amalagalite::Database this schema is associated with.
    attr_reader :db

    #
    # Create a new instance of Schema
    #
    def initialize( db, catalog = 'main', master_table = 'sqlite_master' )
      @db             = db
      @catalog        = catalog
      @schema_version = nil
      @tables         = {}
      @views          = {}
      @master_table   = master_table

      if @master_table == 'sqlite_master' then
        @temp_schema = ::Amalgalite::Schema.new( db, 'temp', 'sqlite_temp_master')
      else
        @temp_schema = nil
      end
      load_schema!
    end

    def catalog_master_table
      "#{catalog}.#{@master_table}"
    end

    def temporary?
      catalog == "temp"
    end

    def dirty?()
      return true  if (@schema_version != self.current_version)
      return false unless @temp_schema
      return @temp_schema.dirty?
    end

    def current_version
      @db.first_value_from("PRAGMA #{catalog}.schema_version")
    end

    #
    # load the schema from the database
    def load_schema!
      load_tables
      load_views
      if @temp_schema then
        @temp_schema.load_schema!
      end
      @schema_version = self.current_version
      nil
    end

    ##
    # return the tables, reloading if dirty.
    # If there is a temp table and a normal table with the same name, then the
    # temp table is the one that is returned in the hash.
    def tables
      load_schema! if dirty?
      t = @tables
      if @temp_schema then
        t = @tables.merge( @temp_schema.tables )
      end
      return t
    end

    ##
    # load all the tables
    #
    def load_tables
      @tables = {}
      @db.execute("SELECT tbl_name FROM #{catalog_master_table} WHERE type = 'table' AND name != 'sqlite_sequence'") do |table_info|
        table = load_table( table_info['tbl_name'] )
        table.indexes = load_indexes( table )
        @tables[table.name] = table
      end
      return @tables
    end

    ##
    # Load a single table
    def load_table( table_name )
      rows = @db.execute("SELECT tbl_name, sql FROM #{catalog_master_table} WHERE type = 'table' AND tbl_name = ?", table_name)
      table_info = rows.first
      table = nil
      if table_info then
        table = Amalgalite::Table.new( table_info['tbl_name'], table_info['sql'] )
        table.schema = self
        table.columns = load_columns( table )
        table.indexes = load_indexes( table )
        @tables[table.name] = table
      end
      return table
    end

    ##
    # load all the indexes for a particular table
    #
    def load_indexes( table )
      indexes = {}

      @db.prepare("SELECT name, sql FROM #{catalog_master_table} WHERE type ='index' and tbl_name = $name") do |idx_stmt|
        idx_stmt.execute( "$name" => table.name) do |idx_info|
          indexes[idx_info['name']] = Amalgalite::Index.new( idx_info['name'], idx_info['sql'], table )
        end
      end

      @db.execute("PRAGMA index_list( #{@db.quote(table.name)} );") do |idx_list|
        idx = indexes[idx_list['name']]

        # temporary indexes do not show up in the previous list
        if idx.nil? then
          idx = Amalgalite::Index.new( idx_list['name'], nil, table )
          indexes[idx_list['name']] = idx
        end

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
      @db.execute("PRAGMA #{catalog}.table_info(#{@db.quote(table.name)})") do |row|
        col = Amalgalite::Column.new( catalog,  table.name, row['name'], row['cid'])

        col.default_value       = row['dflt_value']

        col.declared_data_type  = row['type']
        col.not_null_constraint = row['notnull']
        col.primary_key         = row['pk']

        # need to remove leading and trailing ' or " from the default value
        if col.default_value and col.default_value.kind_of?( String ) and ( col.default_value.length.to_i >= 2 ) then
          fc = col.default_value[0].chr
          lc = col.default_value[-1].chr
          if fc == lc and ( fc == "'" || fc == '"' ) then
            col.default_value = col.default_value[1..-2]
          end
        end

        unless table.temporary? then
          # get more exact information
          @db.api.table_column_metadata( catalog, table.name, col.name ).each_pair do |key, value|
            col.send("#{key}=", value)
          end
        end
        col.schema = self
        cols[col.name] = col
        idx += 1
      end
      return cols
    end

    ##
    # return the views, reloading if dirty
    #
    # If there is a temp view, and a regular view of the same name, then the
    # temporary view is the one that is returned in the hash.
    #
    def views
      reload_schema! if dirty?
      v = @views
      if @temp_schema then
        v = @views.merge( @temp_schema.views )
      end
      return v
    end

    ##
    # load a single view
    #
    def load_view( name )
      rows = @db.execute("SELECT name, sql FROM #{catalog_master_table} WHERE type = 'view' AND name = ?", name )
      view_info = rows.first
      view = Amalgalite::View.new( view_info['name'], view_info['sql'] )
      view.schema = self
      return view
    end

    ##
    # load all the views for the database
    #
    def load_views
      @db.execute("SELECT name, sql FROM #{catalog_master_table} WHERE type = 'view'") do |view_info|
        view = load_view( view_info['name'] )
        @views[view.name] = view
      end
      return @views
    end
  end
end
