require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
require 'amalgalite/sqlite3'

describe "Amalgalite::SQLite3" do
  it "says if SQLite3 is in threadsafe mode or not" do
    Amalgalite::SQLite3.threadsafe?.should == true
  end

  it "knows if an SQL statement is complete" do
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable;").should == true
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable;", :utf16 => true).should == true
  end
  
  it "knows if an SQL statement is not complete" do
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable ").should == false
    Amalgalite::SQLite3.complete?("SELECT * FROM sometable WHERE ", :utf16 => true).should == false
  end

  it "knows how much memory it has used" do
    Amalgalite::SQLite3.memory_used.should >= 0
  end
  
  it "knows the maximum amount of memory it has used so far" do
    Amalgalite::SQLite3.memory_highwater_mark.should >= 0
  end
  
  it "can reset it maximum memory usage counter" do
    Amalgalite::SQLite3.memory_highwater_mark_reset!.should >= 0
  end

  it "can produce random data" do
    Amalgalite::SQLite3.randomness( 42 ).size.should == 42
  end
end
