require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'

describe Amalgalite::Blob do
  DATA_FILE = File.expand_path( File.join( File.dirname(__FILE__), "iso-3166-country.txt" ) )
  before(:each) do
    @blob_db_name = File.join(File.dirname( __FILE__ ), "blob.db")
    File.unlink @blob_db_name if File.exist?( @blob_db_name )
    @db = Amalgalite::Database.new( @blob_db_name )
    @schema_sql = <<-SQL
      CREATE TABLE blobs(
        id      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name    VARCHAR(128) NOT NULL UNIQUE,
        data    TEXT ); 
    SQL
    @db.execute( @schema_sql )
    @junk_file = File.join( File.dirname(__FILE__), "test_output")
  end

  after(:each) do
    @db.close
    File.unlink @blob_db_name if File.exist?( @blob_db_name )
    File.unlink @junk_file    if File.exist?( @junk_file )
  end

  { :file   => DATA_FILE,
    :string => IO.read( DATA_FILE ),
    :io     => StringIO.new( IO.read( DATA_FILE ) ) }.each_pair do |style, data |
    describe "inserts a blob from a #{style}" do
      before(:each) do
        column = @db.schema.tables['blobs'].columns['data']
        @db.execute("INSERT INTO blobs(name, data) VALUES ($name, $data)",
                    { "$name" => DATA_FILE,
                      "$data" => Amalgalite::Blob.new( style => data,
                                                      :column => column ) } )
        @db.execute("VACUUM")
      end

      after(:each) do
        @db.execute("DELETE FROM blobs")
        data.rewind if data.respond_to?( :rewind )
      end

      it "and retrieves the data as a single value" do
        all_rows = @db.execute("SELECT name,data FROM blobs")
        all_rows.size.should == 1;
        all_rows.first['name'].should == DATA_FILE
        all_rows.first['data'].should_not be_incremental
        all_rows.first['data'].to_string_io.string.should == IO.read( DATA_FILE )
      end

      it "and retrieves the data using incremental IO" do
        all_rows = @db.execute("SELECT * FROM blobs")
        all_rows.size.should == 1;
        all_rows.first['name'].should == DATA_FILE
        all_rows.first['data'].should be_incremental
        all_rows.first['data'].to_string_io.string.should == IO.read( DATA_FILE )
      end

      it "writes the data to a file " do
        all_rows = @db.execute("SELECT * FROM blobs")
        all_rows.size.should == 1;
        all_rows.first['name'].should == DATA_FILE
        all_rows.first['data'].should be_incremental
        all_rows.first['data'].write_to_file( @junk_file )
        IO.read( @junk_file).should == IO.read( DATA_FILE )
      end
    end
  end



  it "raises an error if initialized incorrectly" do
    lambda{ Amalgalite::Blob.new( :file => "/dev/null", :string => "foo" ) }.should raise_error( Amalgalite::Blob::Error )
  end
end


