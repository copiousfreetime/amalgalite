require 'spec_helper'
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    expect(Amalgalite::SQLite3::VERSION).to match(/\d\.\d\.\d/)
    expect(Amalgalite::SQLite3::Version.to_s).to match( /\d\.\d\.\d/ )
    expect(Amalgalite::SQLite3::Version.runtime_version).to match( /\d\.\d\.\d/ )

    Amalgalite::SQLite3::Version.to_i.should eql(3009002)
    Amalgalite::SQLite3::Version.runtime_version_number.should eql(3009002)

    Amalgalite::SQLite3::Version::MAJOR.should eql(3)
    Amalgalite::SQLite3::Version::MINOR.should eql(9)
    Amalgalite::SQLite3::Version::RELEASE.should eql(2)
    expect(Amalgalite::SQLite3::Version.to_a.size).to eql(3)

    Amalgalite::SQLite3::Version.compiled_version.should be == "3.9.2"
    Amalgalite::SQLite3::Version.compiled_version_number.should be == 3009002
    Amalgalite::SQLite3::Version.compiled_matches_runtime?.should be == true
  end
end
