#!/usr/bin/env ruby

#
# An Amalgalite example showing how to 'require' data in an amalgalite database
#
# We'll make a database with one table, that we store file contents in.
#

$: << "../lib"
$: << "../ext"
require 'rubygems'
require 'amalgalite'

#
# create the database 
#
File.unlink( "lib.db" ) if File.exist?( "lib.db" )
db = Amalgalite::Database.new( "lib.db" )
STDERR.puts "Creating rubylibs table"
db.execute(<<-create)
CREATE TABLE rubylibs(
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  filename  VARCHAR UNIQUE,
  contents  TEXT
)
create


#
# insert some source code into a row
#
db.execute("INSERT INTO rubylibs(filename, contents) VALUES ( $filename, $contents )",
           { "$filename" => "example",
             "$contents" => <<code 
class ExampleCode
  def initialize( x )
    puts "Initializing ExampleCode"
    @x = x
  end
  
  def foo
   puts @x
  end
end
code
})
db.close

require 'amalgalite/requires'
Amalgalite::Requires.new( :dbfile_name => "lib.db" )
require 'example'
e = ExampleCode.new( 'it works!' )
e.foo
                            
