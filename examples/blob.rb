#!/usr/bin/env ruby

#
# An Amalgalite example showing how Blob's can be utilized
#
# We'll make a database with one table, that we store files in.  We'll use the
# Blob incremental IO to store the files and retrieve them from the database
#
# This little program will store 1 or more files in the sqlite3 database when
# the 'store' action is given, and cat a file to stdout on 'retrieve'
#
# e.g.
#
#   ruby blob.rb store a.rb b.rb c.rb # => stores a.rb b.rb and c.rb in the db
#
#   ruby blob.rb retrieve a.rb        # => dumps a.rb to stdout
#

$: << "../lib"
$: << "../ext"
require 'rubygems'
require 'arrayfields'
require 'amalgalite'

def usage 
  STDERR.puts "Usage: #{File.basename($0)} ( store | retrieve )  file(s)"
  exit 1
end

#
# This does the basic command line parsing
#
usage if ARGV.size < 2
action    = ARGV.shift
usage unless %w[ store retrieve ].include? action
file_list = ARGV
usage unless file_list.size > 0

#
# create the database if it doesn't exist
#
db = Amalgalite::Database.new( "filestore.db" )
unless db.schema.tables['files']
  STDERR.puts "Creating files table"
  db.execute(<<-create)
  CREATE TABLE files(
    id     INTEGER PRIMARY KEY AUTOINCREMENT,
    path   VARCHAR UNIQUE,
    data   BLOB
  )
  create
  db.reload_schema!
end


case action
  #
  # if we are doing the store action, then loop over the files and store them in
  # the database.  This will use incremental IO to store the files directly from
  # the file names. 
  #
  # It is slightly strange in that you have to tell the Blob object what column
  # it is going to, but that is necessary at this point to be able to hook
  # automatically into the lower level incremental blob IO api.
  #
  # This also shows using the $var syntax for binding name sql values in a
  # prepared statement.
  #
when 'store'
  db.transaction do |db_in_trans|
    db_in_trans.prepare("INSERT INTO files(path, data) VALUES( $path, $data )") do |stmt|
      file_list.each do |file_path|
        begin        
          if File.exist?( file_path ) then
            stmt.execute( "$path" => file_path, 
                          "$data" => Amalgalite::Blob.new( :file => file_path, :column => db_in_trans.schema.tables['files'].columns['data'] ) )
            STDERR.puts "inserted #{file_path} with id #{db.last_insert_rowid}"
          else
            STDERR.puts "#{file_path} does not exist"
          end
        rescue => e
          STDERR.puts e
        end
      end
    end
  end
  STDERR.puts "inserted a total of #{db.total_changes} changes"

  #
  # dump the file that matches the right path to stdout.  This also shows
  # positional sql varible binding using the '?' syntax.
  #
when 'retrieve'
  db.execute("SELECT id, path, data FROM files WHERE path = ?", file_list.first) do |row|
  STDERR.puts "Dumping #{row['path']} to stdout"
  row['data'].write_to_io( STDOUT )
  end
end
db.close
