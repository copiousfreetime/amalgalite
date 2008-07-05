#!/usr/bin/env ruby

#
# Basic amalgalite example creating a table, inserting rows and doing various
# selects and prepared statements
#
require 'rubygems'
require 'amalgalite'

#
# Create a database, this will create the DB if it doesn't exist
#
puts "Opening database (version #{Amalgalite::Version})"
db = Amalgalite::Database.new("gems.db")

#
# Setup taps into profile and trace information of sqlite, the profile tap will
# goto the profile_tap.log file and the trace information will go to the
# trace_tap.log file
#
puts "Establishing taps"
db.trace_tap   = Amalgalite::Taps::IO.new( trace_tap_file = File.open("trace_tap.log", "w+") )
db.profile_tap = Amalgalite::Taps::IO.new( profile_tap_file = File.open("profile_tap.log", "w+") )

#
# Create the schema unless it already exists in the table.  The meta information
# about the database schema is available as the result of the db.schema method
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
  db.reload_schema!
end

#
# Get some data from the system to insert into the database.  Since everyone
# probably has gems installed, that's a ready known piece of information.  We'll
# just pull in the latest version of each installed gem and dump some meta
# information into a db for testing.
#
latest_specs = Gem.source_index.latest_specs

puts "Inserting #{latest_specs.size} rows of gem information..."
before = Time.now

# Inserting bulk rows as a transaction is good practice with SQLite, it is
# MUCH faster.  
db.transaction do |db_in_transaction|
  db_in_transaction.prepare("INSERT INTO gems(name, version, author) VALUES( :name, :version, :author );") do |stmt|
    latest_specs.each do |spec|
      insert_data = {}
      insert_data[':name']    = spec.name.to_s
      insert_data[':version'] = spec.version.to_s
      insert_data[':author']  = spec.authors.join(' ')
      #puts "Inserting #{insert_data.inspect}"
      stmt.execute( insert_data )
    end
  end
end
puts "Took #{Time.now - before} seconds"
puts "Done Inserting"

authors_by_number = db.execute("SELECT author, count( name ) as num_gems FROM gems GROUP BY author ORDER BY num_gems DESC")
favorite_author   = authors_by_number.first
puts "Your favorite gem author is <#{favorite_author['author']}>, with #{favorite_author['num_gems']} gems installed."

#
# Now we'll look at the profile sampler and see what information it traced about
# our behavoir.
#
db.profile_tap.samplers.each do |stat_name, stat_values|
  puts "-" * 20
  puts stat_values.to_s
end

#
# Clear out the taps (not really necessary, just cleaning up)
#
db.trace_tap = profile_tap = nil

#
# close things down
#
db.close
trace_tap_file.close
profile_tap_file.close
