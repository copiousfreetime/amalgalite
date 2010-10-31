require 'fastercsv'
module Amalgalite
  ##
  # A class to deal with importing CSV data into a single table in the
  # database.
  #
  class CSVTableImporter
    def initialize( csv_path, database, table_name, options = {} )
      @csv_path   = File.expand_path( csv_path )
      @database   = database
      @table_name = table_name
      @table      = @database.schema.tables[@table_name]
      @options    = options
      validate
    end

    def run
      @database.transaction do |db|
        db.prepare( insert_sql ) do |stmt|
          ::FasterCSV.foreach( @csv_path, @options ) do |row|
            stmt.execute( row )
          end
        end
      end
    end

    ##
    # The column names of the import table in definiation order
    #
    def column_names
      @table.columns_in_order.collect { |c| c.name }
    end

    ##
    # The columns used for the insertion.  This is either #column_names
    # or the value out of @options[:headers] if that value is an Array
    #
    def insert_column_list
      column_list = self.column_names
      if Array === @options[:headers]  then
        column_list = @options[:headers]
      end
      return column_list
    end

    ##
    # The prepared statement SQL that is used for the import
    #
    def insert_sql
      column_sql = insert_column_list.join(",")
      vars       = insert_column_list.collect { |x| "?" }.join(",")
      return "INSERT INTO #{@table_name}(#{column_sql}) VALUES (#{vars})"
    end

    def table_list
      @database.schema.tables.keys
    end

    ##
    # validate that the arguments for initialization are valid and that the #run
    # method will probably execute
    #
    def validate
      raise ArgumentError, "CSV file #{@csv_path} does not exist" unless File.exist?( @csv_path )
      raise ArgumentError, "CSV file #{@csv_path} is not readable" unless File.readable?( @csv_path )
      raise ArgumentError, "The table '#{@table_name} is not found in the database.  The known tables are #{table_list.sort.join(", ")}" unless @table
    end
  end
end
