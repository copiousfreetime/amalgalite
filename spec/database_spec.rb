require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'

describe Amalgalite::Database do
  before(:each) do
    @db_name = "test.db"
  end

  after(:each) do
    File.unlink @db_name if File.exist?( @db_name )
  end

  it "can create a new database" do
    db = Amalgalite::Database.new( @db_name )
    db.instance_of?(Amalgalite::Database) 
    db.api.instance_of?(Amalgalite::SQLite3::Database) 
    File.exist?(@db_name).should == true
  end

  it "creates a new UTF-8 database (need exec to check pragma encoding)"
  it "creates a new UTF-16 database (need exec to check pragma encoding)" 

  it "raises an error if the file does not exist and the database is opened with a non-create mode" do
    lambda { Amalgalite::Database.new( @db_name, "r") }.should raise_error(Amalgalite::SQLite3::Error)
    lambda { Amalgalite::Database.new( @db_name, "r+") }.should raise_error(Amalgalite::SQLite3::Error)
  end

  it "raises an error if an invalid mode is used" do
    lambda { Amalgalite::Database.new( @db_name, "b+" ) }.should raise_error(Amalgalite::Database::InvalidModeError)
  end

  it "can be in autocommit mode"
  it "can be in non-autocommit mode"

  it "prepares a statment" do
    db = Amalgalite::Database.new( @db_name )
    stmt = db.prepare("SELECT datetime()")
    stmt.instance_of?(Amalgalite::Statement)
    stmt.api.instance_of?(Amalgalite::SQLite3::Statement)
  end

  it "raises an error on invalid syntax when preparing a bad sql statement" do
    db = Amalgalite::Database.new( @db_name )
    lambda { db.prepare("SELECT nothing FROM stuf") }.should raise_error(Amalgalite::SQLite3::Error)
  end

  it "closes normally" do
    db = Amalgalite::Database.new( @db_name )
    lambda { db.close }.should_not raise_error( Amalgalite::SQLite3::Error )
  end

  it "returns the id of the last inserted row" do
    db = Amalgalite::Database.new( @db_name )
    db.last_insert_rowid.should == 0
  end

  it "is in autocommit mode by default" do
    db = Amalgalite::Database.new( @db_name )
    db.should be_autocommit
  end

  it "report the number of rows changed with an insert"
end

