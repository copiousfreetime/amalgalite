#!/usr/bin/env ruby

require 'rubygems'
$: << "../lib"
$: << "../ext"
require 'amalgalite'

#--
# Create a database and a table to put some results from the functions in
#--
db = Amalgalite::Database.new( ":memory:" )
db.execute( "CREATE TABLE ftest( data, md5, sha1, sha2_bits, sha2)" )

#------------------------------------------------------------------------------
# Create an MD5 method using the block format of defining an sql fuction
#------------------------------------------------------------------------------
require 'digest/md5'
db.define_function( 'md5' ) do |x|
  Digest::MD5.hexdigest( x.to_s )
end

#------------------------------------------------------------------------------
# Create a SHA1 method using the lambda format of defining an sql function
#------------------------------------------------------------------------------
require 'digest/sha1'
sha1 = lambda do |y|
  Digest::SHA1.hexdigest( y.to_s )
end
db.define_function( "sha1", sha1 )

#------------------------------------------------------------------------------
# Create a SHA2 method using the class format for defining an sql function
# In this one we will allow any number of parameters, but we will only use the
# first two.
#------------------------------------------------------------------------------
require 'digest/sha2'
class SQLSha2
  # track the number of invocations
  attr_reader :call_count

  def initialize
    @call_count = 0
  end

  # the protocol that is used for sql function definition
  def to_proc() self ; end

  # say we take any number of parameters
  def arity
    -1
  end

  # The method that is called by SQLite, must be named 'call'
  def call( *args )
    text = args.shift.to_s
    bitlength = (args.shift || 256).to_i
    Digest::SHA2.new( bitlength ).hexdigest( text )
  end
end
db.define_function('sha2', SQLSha2.new)


#------------------------------------------------------------------------------
# Now we have 3 new sql functions, each defined in one of the available methods
# to define sql functions in amalgalite.  Lets insert some rows and look at the
# results
#------------------------------------------------------------------------------
possible_bits = [ 256, 384, 512 ]
sql = "INSERT INTO ftest( data, md5, sha1, sha2_bits, sha2 ) VALUES( @word , md5( @word ), sha1( @word ), @bits, sha2(@word,@bits) )" 
db.prepare( sql ) do |stmt|
  DATA.each do |word|
    word.strip!
    bits = possible_bits[ rand(3) ]
    puts "Inserting #{word}, #{bits}"
    stmt.execute( { '@word' => word, '@bits' => bits } )
  end
end

#------------------------------------------------------------------------------
# And show the results
#------------------------------------------------------------------------------
puts
puts "Getting results..."
puts
columns = db.schema.tables['ftest'].columns.keys.sort
i = 0
db.execute("SELECT #{columns.join(',')} FROM ftest") do |row|
  i += 1
  puts "-----[ row #{i} ]-" + "-" * 42
  columns.each do |col|
    puts "#{col.ljust(10)} : #{row[col]}"
  end
  puts
end


__END__
some
random
words
with
which
to
play
