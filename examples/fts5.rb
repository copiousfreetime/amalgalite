#!/usr/bin/env ruby
require 'rubygems'
require 'amalgalite'
require 'benchmark'
require 'pathname'

begin
  require 'json'
rescue LoadError 
  abort "'gem install json' to run this example"
end


README = <<_
 This example program assumes that you have available the 'fortune' BSD command dataset.

 execute `fortune -f` to see if you have this command available.
_

fortune_dir = %x[ fortune -f 2>&1 ].split("\n").first.split.last
abort README unless fortune_dir and File.directory?( fortune_dir )

fortune_path = Pathname.new(fortune_dir)

#
# Lets create a database that utilizes FTS5 http://www.sqlite.org/fts5.html
#
#

#
# Create a database, this will create the DB if it doesn't exist
#
puts "Opening database (version #{Amalgalite::VERSION})"
db = Amalgalite::Database.new("fts5.db")

#
# Create the schema unless it already exists in the table.  The meta information
# about the database schema is available as the result of the db.schema method
#
schema = db.schema
unless schema.tables['search'] 
  puts "Create schema"
  db.execute_batch <<-SQL
  CREATE VIRTUAL TABLE search USING fts5(
    filename,
    content
  );

  CREATE TABLE plain (
    filename VARCHAR(128),
    content  TEXT 
  );
  SQL
  db.reload_schema!
end

def each_fortune(path,&block)
  fortune = []
  path.each_line do |line|
    line.strip!
    if line == "%" then
      yield fortune.join("\n")
      fortune.clear
    else 
      fortune << line
    end
  end
end

#
# Only load the data if the db is empty
#
if db.first_value_from( "SELECT count(*) from search" ) == 0 then
  before = Time.now
  idx = 0

  # Inserting bulk rows as a transaction is good practice with SQLite, it is
  # MUCH faster.  
  db.transaction do |db_in_transaction|
    # Iterate over the files in the fortunes dir and split on the fortunes, then 

    fortune_path.each_child do |fortune_file|
      next if fortune_file.directory?
      next if fortune_file.extname == ".dat"
      $stdout.puts "Loading #{fortune_file}"

      each_fortune(fortune_file) do |fortune|
        insert_data  = {
          ':fname'   => fortune_file.to_s,
          ':content' => fortune
        }

        # insert into the FTS5 table
        db_in_transaction.prepare("INSERT INTO search( filename, content ) VALUES( :fname, :content );") do |stmt|
          stmt.execute( insert_data )
        end

        # insert into the normal table for comparison
        db_in_transaction.prepare("INSERT INTO plain( filename, content ) VALUES( :fname, :content );") do |stmt|
          stmt.execute( insert_data )
        end

        idx += 1
        print "Processed #{idx}\r"
        $stdout.flush
      end
      puts "\nFinalizing..."
    end
  end
  puts "Took #{Time.now - before} seconds to insert #{idx} fortunes"
  puts "Done Inserting"
end

doc_count = db.first_value_from( "SELECT count(*) from search" ) 

#
# Now lets do some searching for some various words
#

%w[ president salmon thanks ].each do |word|

  count = 100
  puts
  puts "Searching for '#{word}' #{count} times across #{doc_count} fortunes"
  puts "=" * 60

  Benchmark.bm( 15 ) do |x|

    #
    # search using the fts search to get the cont of tweets with the given word
    #
    x.report('fts5: ') do 
      db.prepare( "SELECT count(filename) FROM search WHERE search MATCH 'content:#{word}'" ) do |stmt|
        count.times do
          stmt.execute
        end
      end
    end

    #
    # search using basic string matching in sqlite.  
    #
    x.report('plain: ') do 
      db.prepare( "SELECT count(filename) FROM plain WHERE content LIKE '% #{word} %'" ) do |stmt|
        count.times do
          stmt.execute
        end
      end
    end
  end
end

