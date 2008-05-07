require File.expand_path(File.join(File.dirname(__FILE__),"..","spec_helper.rb"))
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    Amalgalite::SQLite3::VERSION.should =~ /\d\.\d\.\d/
    Amalgalite::SQLite3::Version.to_s.should =~ /\d\.\d\.\d/
    Amalgalite::SQLite3::Version.to_i.should == 3005008
    Amalgalite::SQLite3::Version::MAJOR.should == 3
    Amalgalite::SQLite3::Version::MINOR.should == 5
    Amalgalite::SQLite3::Version::RELEASE.should == 8
  end
end
