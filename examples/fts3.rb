#!/usr/bin/env ruby
require 'rubygems'
require 'amalgalite'
require 'benchmark'

begin
  require 'json'
rescue LoadError 
  abort "'gem install json' to run this example"
end


README = <<_
 This example programs assumes that you have downloaded the 'Tweets During the
 State of the Union address' dataset from infochimps.com

   http://www.infochimps.com/datasets/tweets-during-state-of-the-union-address

 Please:
   1) download this dataset
   2) bunzip + untar this file
   3) record the location of the 'twitter_stream.txt' file that is in the
      tarball.  
   4) Pass this file as the first parameter to this script.
_

twitter_stream = ARGV.shift
abort README unless twitter_stream and File.readable?( twitter_stream )

#
# Lets create a database that utilizes FTS3 http://www.sqlite.org/fts3.html
#
#

#
# Create a database, this will create the DB if it doesn't exist
#
puts "Opening database (version #{Amalgalite::Version})"
db = Amalgalite::Database.new("fts3.db")

#
# Create the schema unless it already exists in the table.  The meta information
# about the database schema is available as the result of the db.schema method
#
schema = db.schema
unless schema.tables['search'] 
  puts "Create schema"
  db.execute_batch <<-SQL
  CREATE VIRTUAL TABLE search USING fts3(
    filename VARCHAR(128),
    content  TEXT 
  );

  CREATE TABLE plain (
    filename VARCHAR(128),
    content  TEXT 
  );
  SQL
  db.reload_schema!
end

#
# Only load the data if the db is empty
#
if db.first_value_from( "SELECT count(*) from search" ) == 0 then
  before = Time.now
  # 
  # Load the tweets from the file passed on the commandline into the database
  # We just want the text and the tweet id and insert that into the database.
  #

  lines = IO.readlines( twitter_stream )
  idx = 0

  # Inserting bulk rows as a transaction is good practice with SQLite, it is
  # MUCH faster.  
  db.transaction do |db_in_transaction|
    lines.each do |line|

      # quick little parse of the tweet
      json = JSON.parse( line )
      insert_data = {}
      insert_data[':fname']   = json['id']
      insert_data[':content'] = json['text']

      # insert into the FTS3 table
      db_in_transaction.prepare("INSERT INTO search( filename, content ) VALUES( :fname, :content );") do |stmt|
        stmt.execute( insert_data )
      end

      # insert into the normal table for comparison
      db_in_transaction.prepare("INSERT INTO plain( filename, content ) VALUES( :fname, :content );") do |stmt|
        stmt.execute( insert_data )
      end

      idx += 1
      print "Processed #{idx} of #{lines.size}\r"
      $stdout.flush
    end
    puts "Finalizing..."
  end
  puts "Took #{Time.now - before} seconds to insert #{idx} lines of #{lines.size}"
  puts "Done Inserting"
end

doc_count = db.first_value_from( "SELECT count(*) from search" ) 

#
# Now lets do some searching for some various words
#

%w[ president salmon thanks ].each do |word|

  count = 100
  puts
  puts "Searching for '#{word}' across #{doc_count} tweets"
  puts "=" * 60

  Benchmark.bm( 15 ) do |x|

    #
    # search using the fts search to get the cont of tweets with the given word
    #
    x.report('fts3: ') do 
      db.prepare( "SELECT count(filename) FROM search WHERE content MATCH '#{word}'" ) do |stmt|
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

