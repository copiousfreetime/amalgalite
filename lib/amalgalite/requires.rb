require 'amalgalite'
require 'pathname'

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
          connection = ::Amalgalite::Database.new( dbfile_name )
          load_path_db_connections[dbfile_name] = connection
        end
        return connection
      end

      def default_dbfile_name
        "lib.db"
      end

      def default_table_name
        "rubylibs"
      end

      def default_filename_column
        "filename"
      end

      def default_compressed_column
        "compressed"
      end

      def default_contents_column
        "contents"
      end

      # 
      # uncompress gzip data
      #
      def gunzip( data )
        data = StringIO.new( data )
        Zlib::GzipReader.new( data ).read
      end

      #
      # compress data
      #
      def gzip( data )
        zipped = StringIO.new
        Zlib::GzipWriter.wrap( zipped ) do |io|
          io.write( data )
        end
        return zipped.string
      end

      def require( filename )
        if load_path.empty? then
          return false
        else
          load_path.each do |lp|
            if lp.require( filename ) then
              return true
            end
          end
          return false
        end
      end

      #
      # return the files in their dependency order for use for packing into a
      # database
      #
      def require_order
        @require_roder ||= %w[
          amalgalite.rb
          amalgalite/blob.rb
          amalgalite/boolean.rb
          amalgalite/column.rb
          amalgalite/statement.rb
          amalgalite/trace_tap.rb
          amalgalite/profile_tap.rb
          amalgalite/type_map.rb
          amalgalite/type_maps/storage_map.rb
          amalgalite/type_maps/text_map.rb
          amalgalite/type_maps/default_map.rb
          amalgalite/database.rb
          amalgalite/index.rb
          amalgalite/paths.rb
          amalgalite/table.rb
          amalgalite/view.rb
          amalgalite/schema.rb
          amalgalite/version.rb
          amalgalite/sqlite3/version.rb
          amalgalite/sqlite3/constants.rb
          amalgalite/sqlite3/status.rb
          amalgalite/sqlite3/database/status.rb
          amalgalite/sqlite3.rb
          amalgalite/taps/io.rb
          amalgalite/taps/console.rb
          amalgalite/taps.rb
          amalgalite/core_ext/kernel/require.rb
          amalgalite/requires.rb
          amalgalite/packer.rb
       ]
     end
    end

    attr_reader :dbfile_name
    attr_reader :table_name
    attr_reader :filename_column
    attr_reader :contents_column
    attr_reader :compressed_column
    attr_reader :db_connection

    def initialize( opts = {} )
      @dbfile_name       = opts[:dbfile_name]       || Requires.default_dbfile_name
      @table_name        = opts[:table_name]        || Requires.default_table_name
      @filename_column   = opts[:filename_column]   || Requires.default_filename_column
      @contents_column   = opts[:contents_column]   || Requires.default_contents_column
      @compressed_column = opts[:compressed_column] || Requires.default_compressed_column
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

            eval( contents, TOPLEVEL_BINDING, row[filename_column])
            $" << row[filename_column]
          else
            return false
          end
        rescue => e
          raise LoadError, "Failure loading #{filename} from #{dbfile_name} : #{e}"
        end
      end
      return true
    end
  end
end
require 'amalgalite/core_ext/kernel/require'
