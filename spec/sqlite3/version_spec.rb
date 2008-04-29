require File.expand_path(File.join(File.dirname(__FILE__),"..","spec_helper.rb"))
require 'amalgalite/sqlite3/version'

describe "Amalgalite::Sqlite3::Version" do
  it "should have the sqlite3 version" do
    Amalgalite::Sqlite3::VERSION.should =~ /\d\.\d\.\d/
    Amalgalite::Sqlite3::Version.to_s.should =~ /\d\.\d\.\d/
    Amalgalite::Sqlite3::Version.to_i.should == 3005008
    Amalgalite::Sqlite3::Version::MAJOR.should == 3
    Amalgalite::Sqlite3::Version::MINOR.should == 5
    Amalgalite::Sqlite3::Version::RELEASE.should == 8
  end
end
