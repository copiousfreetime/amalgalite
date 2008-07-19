require 'amalgalite'
module Amalgalite
  #
  # Requires encapsulates requiring itesm from the database
  class Requires
    class << self
      def load_path_db_connections
        @load_path_db_connections ||= {}
      end
      def load_path
        @load_path ||= []
      end

      def db_connection_to( dbfile_name )
        unless connection = load_path_db_connections[ dbfile_name ] 
          puts "loading file #{dbfile_name}"
          connection = ::Amalgalite::Database.new( dbfile_name )
          load_path_db_connections[dbfile_name] = connection
        end
        return connection
      end

      def require( filename )
        load_path.each { |lp| lp.require( filename ) }
      end
    end

    attr_reader :dbfile_name
    attr_reader :table_name
    attr_reader :filename_column
    attr_reader :contents_column
    attr_reader :db_connection

    def initialize( opts = {} )
      @dbfile_name     = opts[:dbfile_name]     || "lib.db"
      @table_name      = opts[:table_name]      || "rubylibs"
      @filename_column = opts[:filename_column] || "filename"
      @contents_column = opts[:contents_column] || "contents"
      @db_connection   = Requires.db_connection_to( dbfile_name )
      Requires.load_path << self
    end

    #
    # return the sql to find the file contents for a file in this requires
    #
    def sql
      @sql ||= "SELECT #{filename_column}, #{contents_column} FROM #{table_name} WHERE #{filename_column} = ?"
    end

    #
    # require a file in this database table.  This will check and see if the
    # file is already required.  If it isn't it will select the contents
    # associated with the row identified by the filename and eval those contents
    # within the context of TOPLEVEL_BINDING.  The filename is then appended to
    # $".
    #
    # if the file was required then true is returned, otherwise false 
    #
    def require( filename )
      if $".include?( filename ) then
        return false
      else
        begin
          rows = db_connection.execute(sql, filename)
          row = rows.first
          eval( row[contents_column].to_s, TOPLEVEL_BINDING)
          $" << row[filename_column]
        rescue => e
          raise LoadError, "Failure loading #{filename} from #{dbfile_name} : #{e}"
        end
      end
      return true
    end
  end
end
require 'amalgalite/core_ext/kernel/require'
