#!/usr/bin/env ruby

# An example of requiring all the files in a table via the Bootstrap::lift
# method.
#
# First use the blob.rb example in this same directory to load the a.rb file
# into an example database:
#
#   ruby blob.rb store a.rb
#
# Then run this example.
#

# Require "ONLY" then binary extension, do not +require+ the ruby based code
$: << "../ext"
require 'amalgalite/amalgalite3'

# See what the load path is, notice that it is very small
puts "Before $\" : #{$LOADED_FEATURES.inspect}"

# tell the binary extension to "require" every file in the filestore.db in the
# table 'files' orderd by column 'id'.  The 'path' column is added to $LOADED_FEATURES and the
# code in 'data' is evaled.
Amalgalite::Requires::Bootstrap.lift( "dbfile"          => "filestore.db", 
                                      "table_name"      => "rubylibs", 
                                      "rowid_column"    => "id", 
                                      "filename_column" => "filename", 
                                      "contents_column" => "contents" )

# Notice that a.rb is in the list of files that has been required
puts "After $\" : #{$LOADED_FEATURES.inspect}"

# and look we prove that the code was eval'd appropriately
a = A.new
a.a

