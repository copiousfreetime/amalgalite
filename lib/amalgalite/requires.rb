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

      def default_contents_column
        "contents"
      end

      def create_table_sql( opts = {} )
        table = opts[:table_name] || default_table_name
        filename_column = opts[:filename_column] || default_filename_column
        contents_column = opts[:contents_column] || default_contents_column

        sql = <<-create
        CREATE TABLE #{table} (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        #{filename_column} TEXT UNIQ,
        #{contents_column} BLOB
        );
        create
      end

      def store_dir_in_db( dir, opts = {} )
        store_files_from_dir_in_db( FileList[ "#{dir}/**/*.rb"].to_a, dir, opts)
      end

      # 
      # Stores all the .rb files in a directory into the given database.
      # Any filenames that would match the amalgalite requires items are removed
      # from the list
      #
      def store_files_from_dir_in_db( file_list, dir, opts = {} )
        opts[:dbfile] ||= default_dbfile_name
        opts[:table_name] ||= default_table_name
        opts[:filename_column] ||= default_filename_column
        opts[:contents_column] ||= default_contents_column

        db = Amalgalite::Database.new( opts[:dbfile] )
        unless db.schema.tables[ opts[:table_name] ]
          db.execute( create_table_sql( opts ) )
          db.reload_schema!
        end

        dir = Pathname.new( File.expand_path( dir ) )
        db.transaction do |db_in_trans|
          db_in_trans.prepare("INSERT INTO #{opts[:table_name]}(#{opts[:filename_column]}, #{opts[:contents_column]}) VALUES( $filename, $contents)") do |stmt|
            file_list.each do |file_path|
              rel_path = Pathname.new( file_path ).relative_path_from dir 
              next if Requires.require_order.include?( rel_path.to_s )
              if File.exist?( file_path ) then
                stmt.execute( "$filename" => rel_path,
                              "$contents" => Amalgalite::Blob.new( :file => file_path, :column => db_in_trans.schema.tables[opts[:table_name]].columns[opts[:contents_column]] ) )
              else
                STDERR.puts "#{file_path} does not exist"
              end
            end
          end
        end
      end # def 

      def require( filename )
        if load_path.empty? then
          return false
        else
          return load_path.each { |lp| lp.require( filename ) }
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
       ]
     end
    end

    attr_reader :dbfile_name
    attr_reader :table_name
    attr_reader :filename_column
    attr_reader :contents_column
    attr_reader :db_connection

    def initialize( opts = {} )
      @dbfile_name     = opts[:dbfile_name]     || Requires.default_dbfile_name
      @table_name      = opts[:table_name]      || Requires.default_table_name
      @filename_column = opts[:filename_column] || Requires.default_filename_column
      @contents_column = opts[:contents_column] || Requires.default_contents_column
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
          if rows.size > 0 then
            row = rows.first
            eval( row[contents_column].to_s, TOPLEVEL_BINDING)
            $" << row[filename_column]
          else
            raise LoadError, "no row with filename #{filename} exists in #{dbfile_name}"
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
