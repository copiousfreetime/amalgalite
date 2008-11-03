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

require 'rubygems'
$: << "../lib"
$: << "../ext"
require 'amalgalite'
require 'amalgalite/requires'
VALID_ACTIONS = %w[ list retrieve store ]
def usage 
  STDERR.puts "Usage: #{File.basename($0)} ( #{VALID_ACTIONS.join(' | ')} )  file(s)"
  exit 1
end

#
# This does the basic command line parsing
#
usage if ARGV.size < 1
action    = ARGV.shift
usage unless VALID_ACTIONS.include? action 
file_list = ARGV

#
# create the database if it doesn't exist
#
db = Amalgalite::Database.new( "filestore.db" )

case action
  #
  # list all the files that are stored in the database
  #
when 'list'
  db.execute("SELECT filename FROM rubylibs") do |row|
    puts row['filename']
  end

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
  usage if file_list.empty?
  require 'amalgalite/packer'

  packer = Amalgalite::Packer.new( :dbfile => 'filestore.db',
                                   :compressed => true )
  packer.pack( file_list )

  #
  # dump the file that matches the right path to stdout.  This also shows
  # positional sql varible binding using the '?' syntax.
  #
when 'retrieve'
  usage if file_list.empty?
  db.execute("SELECT id, compressed, filename, contents FROM rubylibs WHERE filename = ?", file_list.first) do |row|
    STDERR.puts "Dumping #{row['filename']} to stdout"
    if row['compressed'] then
      s = row['contents'].to_s
      STDOUT.puts Amalgalite::Requires.gunzip( s )
    else
      row['contents'].write_to_io( STDOUT )
    end
  end
end
db.close
