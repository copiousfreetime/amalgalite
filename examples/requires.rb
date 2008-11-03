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

style = ARGV.shift

#
# create the database 
#
dbfile = Amalgalite::Requires::Bootstrap::DEFAULT_DB
File.unlink( dbfile ) if File.exist?( dbfile )
require 'amalgalite/packer'
options = {}
if style == "compressed" then
  options[:compressed] = true
end
p = Amalgalite::Packer.new( options )
p.pack( [ "require_me.rb" ] )

require 'amalgalite/requires'
Amalgalite::Requires.new( :dbfile_name => p.dbfile )
FileUtils.mv 'require_me.rb', 'rm.rb'
require 'require_me'
e = RequireMe.new( "#{style} style works!" )
e.foo
require 'require_me'

puts 
FileUtils.mv 'rm.rb', 'require_me.rb'
