#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
module Amalgalite
  ##
  # This is the interface to allow Blob objects to be written to and read from
  # the SQLite database.  When using statements, use a Blob object as
  # the wrapper around the source to be written to the row, and a Blob object is
  # returned if the the type mapping warrents during select queries.
  #
  # For instance during an insert:
  #
  #   blob_column = db.schema.tables['blobs'].columns['data']
  #   db.execute("INSERT INTO blobs(name, data) VALUES ( $name, $blob )",
  #             { "$name" => "/path/to/file",
  #               "$blob" => Amalgalite::Blob.new( :file => '/path/to/file',
  #                                                :column => blob_column) } )
  #
  #   db.execute("INSERT INTO blobs(id, data) VALUES ($id, $blob )",
  #             { "$name" => 'blobname',
  #               "$blob" => Amalgalite::Blob.new( :io => "something with .read and .length methods",
  #                                                :column => blob_column) } )
  #
  # On select the blob data needs to be read into an IO object
  #
  #   all_rows = db.execute("SELECT name, blob FROM blobs WHERE name = '/path/to/file' ")
  #   blob_row = all_rows.first
  #   blob_row['blob'].write_to_file( blob_row['name'] )
  #   
  # Or write to an IO object
  #   
  #   blob_results = {}
  #   db.execute("SELECT name, blob FROM blobs") do |row|
  #     io = StringIO.new
  #     row['blob'].write_to_io( io )
  #     blob_results[row['name']] = io
  #     # or use a shortcut
  #     # blob_results[row['name']] = row['blob'].to_string_io
  #   end
  #
  # If using a Blob as a conditional, for instance in a WHERE clause then the
  # Blob must resolvable to a String.
  #
  #   db.execute("SELECT FROM blobs(name, data) WHERE data = $blob",
  #             { "$blob' => Amalgalite::Blob.new( :string => "A string of data" ) })
  #
  class Blob 
    class Error < ::Amalgalite::Error; end
    class << self
      def valid_source_params
        @valid_source_params ||= [ :file, :io, :string, :db_blob ]
      end

      def default_block_size
        @default_block_size ||= 8192
      end
    end

    # the object representing the source of the blob
    attr_reader :source 

    # the size in bytes of the of the blob
    attr_reader :length

    # the size in bytes of the blocks of data to move from the source
    attr_reader :block_size

    # the column the blob is associated with
    attr_reader :column

    ##
    # Initialize a new blob, it takes a single parameter, a hash which describes
    # the source of the blob.  The keys of the hash are one of:
    #
    #   :file    : the value is the path to a file on the file system
    #   :io      : the value is an object that responds to the the methods +read+
    #              and +length+.  +read+ should have the behavior of IO#read
    #   :db_blob : not normally used by an end user, used to initialize a blob
    #              object that is returned from an SQL query.
    #   :string  : used when a Blob is part of a WHERE clause or result
    #
    # And additional key of :block_size may be used to indicate the maximum size
    # of a single block of data to move from the source to the destination, this
    # defaults ot 8192.
    #
    def initialize( params )
      if (Blob.valid_source_params & params.keys).size > 1 then
        raise Blob::Error, "Only a one of #{Blob.valid_source_params.join(', ')} is allowed to initialize a Blob.  #{params.keys.join(', ')} were sent"
      end

      @source                  = nil
      @source_length           = 0
      @close_source_after_read = false
      @incremental             = true
      @block_size              = params[:block_size] || Blob.default_block_size
      @column                  = params[:column]     

      raise Blob::Error, "A :column parameter is required for a Blob" unless @column or params.has_key?( :string )

      if params.has_key?( :file ) then
        @source = File.open( params[:file], "r" )
        @length = File.size( params[:file] )
        @close_source_after_read = true
      elsif params.has_key?( :io ) then
        @source = params[:io]
        @length = @source.length
      elsif params.has_key?( :db_blob ) then
        @source = params[:db_blob]
        @length = @source.length
        @close_source_after_read = true
      elsif params.has_key?( :string ) then
        @source = params[:string]
        @length = @source.length
        @incremental = false
      end
    end

    ##
    # close the source when done reading from it
    #
    def close_source_after_read?
      @close_source_after_read
    end

    ##
    # is this an incremental Blob or not
    #
    def incremental?
      @incremental
    end

    ##
    # Write the Blob to an IO object
    #
    def write_to_io( io )
      if source.respond_to?( :read ) then
        while buf = source.read( block_size ) do
          io.write( buf )
        end
      else
        io.write( source.to_s )
      end

      if close_source_after_read? then
        source.close
      end
    end

    ##
    # conver the blob to a string
    #
    def to_s
      to_string_io.string
    end

    ##
    # write the Blob contents to a StringIO
    #
    def to_string_io
      sio = StringIO.new
      write_to_io( sio )
      return sio
    end

    ##
    # Write the Blob contents to a File.  
    #
    def write_to_file( filename, modestring="w" )
      File.open(filename, modestring) do |f|
        write_to_io( f )
      end
    end

    ##
    # Write the Blob contents to the column.  This assumes that the row_id to
    # insert into is the last row that was inserted into the db
    #
    def write_to_column!
      last_rowid = column.schema.db.last_insert_rowid
      SQLite3::Blob.new( column.schema.db.api, column.db, column.table, column.name, last_rowid, "w" ) do |sqlite_blob|
        write_to_io( sqlite_blob )
      end
    end
  end
end
