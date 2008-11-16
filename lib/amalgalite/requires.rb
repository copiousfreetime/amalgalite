require 'amalgalite'
require 'pathname'
require 'zlib'

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

      #
      # Global option to say whether to fall back to the original ruby requires
      # or not
      def fallback_to_ruby_requires
        @fallback_to_ruby_requires ||= true
      end

      #
      # Set whether or not to fallback to the original ruby requires or not.
      #
      def fallback_to_ruby_requires=( fallback )
        @fallback_to_ruby_requires = fallback
      end

      def db_connection_to( dbfile_name )
        unless connection = load_path_db_connections[ dbfile_name ] 
          connection = ::Amalgalite::Database.new( dbfile_name )
          load_path_db_connections[dbfile_name] = connection
        end
        return connection
      end

      # 
      # Setting a class level variable as a flag to know what we are currently
      # in the middle of requiring
      #
      def requiring
        @requiring ||= []
      end

      def default_dbfile_name
        Bootstrap::DEFAULT_DB
      end

      def default_table_name
        Bootstrap::DEFAULT_TABLE
      end

      def default_filename_column
        Bootstrap::DEFAULT_FILENAME_COLUMN
      end

      def default_compressed_column
        Bootstrap::DEFAULT_COMPRESSED_COLUMN
      end

      def default_contents_column
        Bootstrap::DEFAULT_CONTENTS_COLUMN
      end

      def require( filename )
        if load_path.empty? then
          return false
        elsif $".include?( filename ) then
          return false
        elsif Requires.requiring.include?( filename ) then 
          return false
        else
          Requires.requiring << filename
          load_path.each do |lp|
            if lp.require( filename ) then
              Requires.requiring.delete( filename )
              return true
            end
          end
          Requires.requiring.delete( filename )
          raise ::LoadError, "no such file to load -- #{filename}"
        end
      end

   end

    attr_reader :dbfile_name
    attr_reader :table_name
    attr_reader :filename_column
    attr_reader :contents_column
    attr_reader :compressed_column
    attr_reader :db_connection

    def initialize( opts = {} )
      @dbfile_name       = opts[:dbfile_name]       || Bootstrap::DEFAULT_DB
      @table_name        = opts[:table_name]        || Bootstrap::DEFAULT_TABLE
      @filename_column   = opts[:filename_column]   || Bootstrap::DEFAULT_FILENAME_COLUMN
      @contents_column   = opts[:contents_column]   || Bootstrap::DEFAULT_CONTENTS_COLUMN
      @compressed_column = opts[:compressed_column] || Bootstrap::DEFAULT_COMPRESSED_COLUMN
      @db_connection   = Requires.db_connection_to( dbfile_name )
      Requires.load_path << self
    end

    #
    # return the sql to find the file contents for a file in this requires
    #
    def sql
      @sql ||= "SELECT #{filename_column}, #{compressed_column}, #{contents_column} FROM #{table_name} WHERE #{filename_column} = ?"
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
          if rows.size > 0 then
            row = rows.first
            contents = row[contents_column].to_s
            if row[compressed_column] then 
              contents = Requires.gunzip( contents )
            end

            eval( contents, TOPLEVEL_BINDING, row[filename_column] )
            $" << row[filename_column]
            return true
          else
            return false
          end
        rescue => e
          raise ::LoadError, "Failure loading #{filename} from #{dbfile_name} : #{e}"
        end
      end
    end
  end
end
require 'amalgalite/core_ext/kernel/require'
