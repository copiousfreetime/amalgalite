require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
require 'amalgalite/sqlite3'
require 'rbconfig'

describe "Amalgalite::SQLite3" do
  it "is threadsafe is ruby is compiled with pthread support, in this case that is (#{RbConfig::CONFIG['configure_args'].include?( "--enable-pthread" )})" do
    Amalgalite::SQLite3.threadsafe?.should eql(RbConfig::CONFIG['configure_args'].include?( "--enable-pthread" ))
  end

  it "knows if an SQL statement is complete" do
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable;").should eql(true)
    #Amalgalite::SQLite3.complete?("SELECT * FROM sometable;", :utf16 => true).should eql(true)
  end
  
  it "knows if an SQL statement is not complete" do
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable ").should eql(false)
    #Amalgalite::SQLite3.complete?("SELECT * FROM sometable WHERE ", :utf16 => true).should eql(false)
  end

  it "can produce random data" do
    Amalgalite::SQLite3.randomness( 42 ).size.should eql(42)
  end

  it "has nil for the default sqlite temporary directory" do
    Amalgalite::SQLite3.temp_directory.should eql(nil)
  end

  it "can set the temporary directory" do
    Amalgalite::SQLite3.temp_directory.should eql(nil)
    Amalgalite::SQLite3.temp_directory = "/tmp/testing"
    Amalgalite::SQLite3.temp_directory.should eql("/tmp/testing")
    Amalgalite::SQLite3.temp_directory = nil
    Amalgalite::SQLite3.temp_directory.should eql(nil)
  end

  it "can escape quoted strings" do
    Amalgalite::SQLite3.escape( "It's a happy day!" ).should eql("It''s a happy day!")
  end

  it "can escape a symble into a string" do
    Amalgalite::SQLite3.escape( :stuff ).should eql("stuff")
    Amalgalite::SQLite3.escape( :"stuff'n" ).should eql("stuff''n")
  end

  it "can quote and escape single quoted strings" do
    Amalgalite::SQLite3.quote( "It's a happy day!" ).should eql("'It''s a happy day!'")
  end

  it "can quote and escape symbols" do
    Amalgalite::SQLite3.quote( :stuff ).should eql("'stuff'")
    Amalgalite::SQLite3.quote( :"stuff'n" ).should eql("'stuff''n'")
  end
end
