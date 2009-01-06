#!/usr/bin/env ruby

require 'rubygems'
$: << "../lib"
$: << "../ext"
require 'amalgalite'

#--
# Create a database and a table to put some results from the functions in
#--
db = Amalgalite::Database.new( ":memory:" )
db.execute( "CREATE TABLE atest( words )" )

#------------------------------------------------------------------------------
# Create unique word count aggregate 
#------------------------------------------------------------------------------
class UniqueWordCount < ::Amalgalite::Aggregate
  attr_accessor :words

  def initialize
    @name = 'unique_word_count'
    @arity = 1
    @words = Hash.new { |h,k| h[k] = 0 }
  end

  def step( str )
    str.split(/\W+/).each do |word|
      words[ word.downcase ] += 1
    end
    return nil
  end

  def finalize
    return words.size
  end
end

db.define_aggregate( 'unique_word_count', UniqueWordCount )

#------------------------------------------------------------------------------
# Now we have a new aggregate function, lets insert some rows into the database
# and see what we can find.
#------------------------------------------------------------------------------
sql = "INSERT INTO atest( words ) VALUES( ? )"
verify = {}
db.prepare( sql ) do |stmt|
  DATA.each do |words|
    words.strip!
    puts "Inserting #{words}"
    stmt.execute( words )
    words.split(/\W+/).each { |w| verify[w] = true }
  end
end

#------------------------------------------------------------------------------
# And show the results
#------------------------------------------------------------------------------
puts
puts "Getting results..."
puts
all_rows = db.execute("SELECT unique_word_count( words ) AS uwc FROM atest")
puts "#{all_rows.first['uwc']} unique words found"
puts "#{verify.size} unique words to verify"

__END__
some random
words with
which
to play
and there should
be a couple of different
words that appear
more than once and
some that appear only
once
