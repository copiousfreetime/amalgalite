#!/usr/bin/env ruby

#
# Basic amalgalite example creating a table, inserting rows and doing various
# selects and prepared statements
#
require 'rubygems'
require 'amalgalite'

#
# Create a database
#
puts "Opening database (version #{Amalgalite::Version})"
db = Amalgalite::Database.new("gems.db")

#
# Setup taps into profile and trace information of sqlite
#
puts "Establishing taps"
db.trace_tap   = Amalgalite::Taps::IO.new( trace_tap_file = File.open("trace_tap.log", "w+") )
db.profile_tap = Amalgalite::Taps::IO.new( profile_tap_file = File.open("profile_tap.log", "w+") )

#
# Create the schema unless it already exists in the table
#
schema = db.schema
unless schema.tables['gems'] 
  puts "Create schema"
  db.execute <<-SQL
  CREATE TABLE gems (
    id      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name    VARCHAR(128),
    version VARCHAR(32),
    author  VARCHAR(128)
  );
  SQL
end

#
# Get some data from the system to insert into the database
#
latest_specs = Gem.source_index.latest_specs

puts "Inserting #{latest_specs.size} rows of gem information..."
  before = Time.now
db.prepare("INSERT INTO gems(name, version, author) VALUES( :name, :version, :author );") do |stmt|
    latest_specs.each do |spec|
      insert_data = {}
      insert_data[':name']    = spec.name.to_s
      insert_data[':version'] = spec.version.to_s
      insert_data[':author']  = spec.authors.join(' ')
      puts "Inserting #{insert_data.inspect}"
      stmt.execute( insert_data )
      stmt.reset!
    end
end
puts "Took #{Time.now - before} seconds"

puts "Done"
puts "Removing taps"
# close things down
db.close

db.profile_tap.samplers.each do |stat_name, stat_values|
  puts "-" * 20
  puts stat_values.to_s
end

db.trace_tap = profile_tap = nil
trace_tap_file.close
profile_tap_file.close

