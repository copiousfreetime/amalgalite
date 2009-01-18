require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
require 'amalgalite/sqlite3'
require 'rbconfig'

describe "Amalgalite::SQLite3" do
  it "is threadsafe is ruby is compiled with pthread support, in this case that is (#{Config::CONFIG['configure_args'].include?( "--enable-pthread" )})" do
    Amalgalite::SQLite3.threadsafe?.should == Config::CONFIG['configure_args'].include?( "--enable-pthread" )
  end

  it "knows if an SQL statement is complete" do
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable;").should == true
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable;", :utf16 => true).should == true
  end
  
  it "knows if an SQL statement is not complete" do
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable ").should == false
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable WHERE ", :utf16 => true).should == false
  end

  it "can produce random data" do
    Amalgalite::SQLite3.randomness( 42 ).size.should == 42
  end

  it "has nil for the default sqlite temporary directory" do
    Amalgalite::SQLite3.temp_directory.should == nil
  end

  it "can set the temporary directory" do
    Amalgalite::SQLite3.temp_directory.should == nil
    Amalgalite::SQLite3.temp_directory = "/tmp/testing"
    Amalgalite::SQLite3.temp_directory.should == "/tmp/testing"
    Amalgalite::SQLite3.temp_directory = nil
    Amalgalite::SQLite3.temp_directory.should == nil
  end
end
