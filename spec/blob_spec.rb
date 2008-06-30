require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'

describe Amalgalite::Statement do
  before(:each) do
    @blob_db_name = File.join(File.dirname( __FILE__ ), "blob.db")
    File.unlink @blob_db_name if File.exist?( @blob_db_name )
    @db = Amalgalite::Database.new( @blob_db_name )
    @schema_sql = <<-SQL
      CREATE TABLE blobs(
        id      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name    VARCHAR(128) NOT NULL UNIQUE,
        data    BLOB ); 
    SQL
    @db.execute( @schema_sql )
  end

  after(:each) do
    @db.close
    #File.unlink @blob_db_name if File.exist?( @blob_db_name )
  end

  it "inserts a blob from a file" do
    datafile = File.expand_path( File.join( File.dirname(__FILE__), "iso-3166-country.txt" ) )
    column = @db.schema.tables['blobs'].columns['data']
    @db.execute("INSERT INTO blobs(name, data) VALUES ($name, $data)",
                { "$name" => datafile,
                  "$data" => Amalgalite::Blob.new( :file => datafile,
                                                   :column => column ) } )
    puts "Data has been inserted..."
    STDOUT.flush
    all_rows = @db.execute("SELECT * FROM blobs")
    all_rows.size.should == 1;
    all_rows.first['name'].should == datafile;
    all_rows.first['data'].to_string_io.string.should == IO.read( datafile )
  end
end
 

