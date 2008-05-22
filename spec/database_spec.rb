require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'
require 'amalgalite/taps/io'
require 'amalgalite/taps/console'

describe Amalgalite::Database do
  before(:each) do
    @schema = IO.read( SpecInfo.test_schema_file )
    @iso_db_file = SpecInfo.make_iso_db
    @iso_db = Amalgalite::Database.new( SpecInfo.make_iso_db )
  end

  after(:each) do
    File.unlink SpecInfo.test_db if File.exist?( SpecInfo.test_db )
    @iso_db.close
    File.unlink @iso_db_file if File.exist?( @iso_db_file )
  end

  it "can create a new database" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.instance_of?(Amalgalite::Database) 
    db.api.instance_of?(Amalgalite::SQLite3::Database) 
    File.exist?( SpecInfo.test_db ).should == true
  end

  it "creates a new UTF-8 database (need exec to check pragma encoding)" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute_batch( @schema );
    db.should_not be_utf16
    db.encoding.should == "UTF-8"
  end

  it "creates a new UTF-16 database (need exec to check pragma encoding)" 

  it "raises an error if the file does not exist and the database is opened with a non-create mode" do
    lambda { Amalgalite::Database.new( SpecInfo.test_db, "r") }.should raise_error(Amalgalite::SQLite3::Error)
    lambda { Amalgalite::Database.new( SpecInfo.test_db, "r+") }.should raise_error(Amalgalite::SQLite3::Error)
  end

  it "raises an error if an invalid mode is used" do
    lambda { Amalgalite::Database.new( SpecInfo.test_db, "b+" ) }.should raise_error(Amalgalite::Database::InvalidModeError)
  end

  it "can be in autocommit mode"
  it "can be in non-autocommit mode"

  it "prepares a statment" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    stmt = db.prepare("SELECT datetime()")
    stmt.instance_of?(Amalgalite::Statement)
    stmt.api.instance_of?(Amalgalite::SQLite3::Statement)
  end

  it "raises an error on invalid syntax when preparing a bad sql statement" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.prepare("SELECT nothing FROM stuf") }.should raise_error(Amalgalite::SQLite3::Error)
  end

  it "closes normally" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.close }.should_not raise_error( Amalgalite::SQLite3::Error )
  end

  it "returns the id of the last inserted row" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.last_insert_rowid.should == 0
  end

  it "is in autocommit mode by default" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.should be_autocommit
  end

  it "report the number of rows changed with an insert"

  it "can immediately execute an sql statement " do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute( "CREATE TABLE t1( x, y, z )" ).should be_empty
  end

  it "can execute a batch of commands" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute_batch( @schema ).should == 5
  end

  it "traces the execution of code" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    sql = "CREATE TABLE trace_test( x, y, z)"
    s = db.trace_tap = ::Amalgalite::Taps::StringIO.new
    db.execute( sql )
    db.trace_tap.string.should== "registered as trace tap\n#{sql}\n"
    db.trace_tap = nil
    s.string.should== "registered as trace tap\n#{sql}\nunregistered as trace tap\n"
  end

  it "raises an exception if the wrong type of object is used for tracing" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.trace_tap = Object.new }.should raise_error(Amalgalite::Error)
  end

  it "raises an exception if the wrong type of object is used for profile" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.profile_tap = Object.new }.should raise_error(Amalgalite::Error)
  end

  it "profiles the execution of code" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    s = db.profile_tap = ::Amalgalite::Taps::StringIO.new
    db.execute_batch( @schema )
    db.profile_tap.samplers.size.should == 6
    db.profile_tap = nil
    s.string.should =~ /unregistered as profile tap/m
  end

  it "can use something that responds to 'write' as a tap" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    s2 = db.trace_tap   = StringIO.new
    s2.string.should == "registered as trace tap"
  end

  it "can clear all registered taps" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    s = db.profile_tap = ::Amalgalite::Taps::StringIO.new
    db.trace_tap = s
    db.execute_batch( @schema )
    db.profile_tap.samplers.size.should == 6
    db.clear_taps!
    s.string.should =~ /unregistered as trace tap/m
    s.string.should =~ /unregistered as profile tap/m
  end

  it "raises an error if a transaction is attempted within a transaction" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.transaction do |db2|
      lambda{ db2.transaction }.should raise_error(Amalgalite::Error)
    end
  end


end

