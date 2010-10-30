require File.expand_path(File.join(File.dirname(__FILE__),"..","spec_helper.rb"))
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    Amalgalite::SQLite3::VERSION.should =~ /\d\.\d\.\d/
    Amalgalite::SQLite3::Version.to_s.should =~ /\d\.\d\.\d/
    Amalgalite::SQLite3::Version.runtime_version.should =~ /\d\.\d\.\d/

    Amalgalite::SQLite3::Version.to_i.should eql(3007003)
    Amalgalite::SQLite3::Version.runtime_version_number.should eql(3007003)

    Amalgalite::SQLite3::Version::MAJOR.should eql(3)
    Amalgalite::SQLite3::Version::MINOR.should eql(7)
    Amalgalite::SQLite3::Version::RELEASE.should eql(3)
    Amalgalite::SQLite3::Version.to_a.should have(3).items

    Amalgalite::SQLite3::Version.compiled_version.should == "3.7.3"
    Amalgalite::SQLite3::Version.compiled_version_number.should == 3007003
    Amalgalite::SQLite3::Version.compiled_matches_runtime?.should == true
  end
end
