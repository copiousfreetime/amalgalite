require File.expand_path(File.join(File.dirname(__FILE__),"..","spec_helper.rb"))
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    Amalgalite::SQLite3::VERSION.should =~ /\d\.\d\.\d/
    Amalgalite::SQLite3::Version.to_s.should =~ /\d\.\d\.\d/
    Amalgalite::SQLite3::Version.to_i.should == 3006000
    Amalgalite::SQLite3::Version::MAJOR.should == 3
    Amalgalite::SQLite3::Version::MINOR.should == 6
    Amalgalite::SQLite3::Version::RELEASE.should == 0
    Amalgalite::SQLite3::Version.to_a.should have(3).items
  end
end
