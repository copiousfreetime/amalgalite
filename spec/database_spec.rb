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
    db.db.instance_of?(Amalgalite::SQLite3::Database) 
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

end

