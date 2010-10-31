require 'optparse'
require 'ostruct'
require 'pathname'
require 'zlib'

require 'amalgalite'
module Amalgalite
  #
  # Pack items into an amalgalite database.  
  #
  class Packer
    attr_reader :packing_list
    attr_reader :dbfile
    attr_reader :options

    class << self
      def default_options
        {
          :table_name        => Requires::Bootstrap::DEFAULT_TABLE,
          :filename_column   => Requires::Bootstrap::DEFAULT_FILENAME_COLUMN,
          :contents_column   => Requires::Bootstrap::DEFAULT_CONTENTS_COLUMN,
          :compressed_column => Requires::Bootstrap::DEFAULT_COMPRESSED_COLUMN,
          :strip_prefix      => Dir.pwd,
          :compressed        => false,
          :verbose           => false,
        }
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

      # 
      # uncompress gzip data
      #
      def gunzip( data )
        data = StringIO.new( data )
        Zlib::GzipReader.new( data ).read
      end


      #
      # return the files in their dependency order for use for packing into a
      # database
      #
      def amalgalite_require_order
        @require_order ||= %w[
          amalgalite.rb
          amalgalite/sqlite3/database/function.rb
          amalgalite/aggregate.rb
          amalgalite/blob.rb
          amalgalite/boolean.rb
          amalgalite/busy_timeout.rb
          amalgalite/column.rb
          amalgalite/statement.rb
          amalgalite/trace_tap.rb
          amalgalite/profile_tap.rb
          amalgalite/type_map.rb
          amalgalite/type_maps/storage_map.rb
          amalgalite/type_maps/text_map.rb
          amalgalite/type_maps/default_map.rb
          amalgalite/function.rb
          amalgalite/progress_handler.rb
          amalgalite/csv_table_importer.rb
          amalgalite/database.rb
          amalgalite/index.rb
          amalgalite/memory_database.rb
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
          amalgalite/packer.rb
          amalgalite/core_ext/kernel/require.rb
          amalgalite/requires.rb
        ]
      end
    end

    # 
    # Create a new packer instance with the list of items to pack and all the
    # options
    #
    def initialize(  options = {} )
      @options = Packer.default_options.merge( options )
      @dbfile  = @options[:dbfile] || Requires::Bootstrap::DEFAULT_DB
    end

    # 
    # The SQL to create the table for storing ruby code
    #
    def create_table_sql
      sql = <<-create
      CREATE TABLE #{options[:table_name]} (
      id                   INTEGER PRIMARY KEY AUTOINCREMENT,
      #{options[:filename_column]}   TEXT UNIQUE,
      #{options[:compressed_column]} BOOLEAN,
      #{options[:contents_column]}   BLOB
      );
      create
    end

    #
    # Make sure that the dbfile exists and has the appropriate schema.  
    #
    def check_db( db )
      if db.schema.tables[ options[:table_name] ] and options[:drop_table] then
        STDERR.puts "Dropping table #{options[:table_name]}" if options[:verbose]
        db.execute("DROP TABLE #{options[:table_name]}")
        db.reload_schema!
      end

      unless db.schema.tables[ options[:table_name] ]
        db.execute( create_table_sql )
        db.reload_schema!
      end

    end


    #
    # Stores all the .rb files in the list into the given database.  The prefix
    # is the file system path to remove from the front of the path on each file
    #
    # manifest is an array of OpenStructs.  
    #
    def pack_files( manifest )
      db = Amalgalite::Database.new( dbfile )
      check_db( db )
      max_width = manifest.collect{ |m| m.require_path.length }.sort.last
      contents_column = db.schema.tables[ options[:table_name] ].columns[ options[:contents_column] ]
      db.transaction do |trans|
        manifest.each do |file_info|
          msg  = "  -> #{file_info.require_path.ljust( max_width )} : "
          begin
            if options[:merge] then
              trans.execute( "DELETE FROM #{options[:table_name]} WHERE #{options[:filename_column]} = ?", file_info.require_path )
            end

            trans.prepare("INSERT INTO #{options[:table_name]}(#{options[:filename_column]}, #{options[:compressed_column]}, #{options[:contents_column]}) VALUES( $filename, $compressed, $contents)") do |stmt|
              contents = IO.readlines( file_info.file_path )
              if options[:self] then
                contents.each { |l| l.gsub!( /^(\s*require .*)$/m, "# commented out by #{self.class.name} \\1") }
              end
              contents = contents.join

              if options[:compressed] then
                contents = Packer.gzip( contents )
              end
              content_io = StringIO.new( contents )
              stmt.execute( "$filename"   => file_info.require_path,
                            "$contents"   => Amalgalite::Blob.new( :io => content_io,
                                                                   :column => contents_column ),
                            "$compressed" => options[:compressed] )
              STDERR.puts "#{msg} stored #{file_info.file_path}" if options[:verbose]
            end
          rescue => e
            STDERR.puts "#{msg} error #{e}"
          end
        end
      end
    end

    #
    # given a file, see if it can be found in the ruby load path, if so, return that
    # full path
    #
    def full_path_of( rb_file )
      $LOAD_PATH.each do |load_path|
        guess = File.expand_path( File.join( load_path, rb_file ) )
        return guess if File.exist?( guess )
      end
      return nil
    end

    # 
    # Make the manifest for packing
    #
    def make_manifest( file_list )
      manifest = []
      prefix_path = ::Pathname.new( options[:strip_prefix] )
      file_list.each do |f|
        file_path = ::Pathname.new( File.expand_path( f ) )
        m = ::OpenStruct.new
        # if it is a directory then grab all the .rb files from it
        if File.directory?( file_path ) then
          manifest.concat( make_manifest( Dir.glob( File.join( f, "**", "*.rb" ) ) ) )
          next
        elsif File.readable?( file_path ) then
          m.require_path = file_path.relative_path_from( prefix_path )
          m.file_path    = file_path.realpath.to_s
        elsif lp = full_path_of( f ) then
          m.require_path = f
          m.file_path    = lp
        else
          STDERR.puts "Unable to add #{f} to the manifest, cannot find the file on disk"
          next
        end
        m.require_path = m.require_path.to_s[ /\A(.*)\.rb\Z/, 1]
        manifest << m
      end
      return manifest
    end

    #
    # Given a list of files pack them into the associated database and table.
    #
    def pack( file_list )
      manifest = make_manifest( file_list )
      pack_files( manifest )
    end
  end
end
