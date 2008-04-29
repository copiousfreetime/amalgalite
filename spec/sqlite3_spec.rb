require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
require 'amalgalite/sqlite3'

describe "Amalgalite::Sqlite3" do
  it "says if Sqlite3 is in threadsafe mode or not" do
    Amalgalite::Sqlite3.threadsafe?.should == true
  end
end
