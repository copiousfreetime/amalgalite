require 'spec_helper'
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    expect(Amalgalite::SQLite3::VERSION).to match(/\d+\.\d+\.\d+/)
    expect(Amalgalite::SQLite3::Version.to_s).to match( /\d+\.\d+\.\d+/ )
    expect(Amalgalite::SQLite3::Version.runtime_version).to match( /\d+\.\d+\.\d+/ )

    Amalgalite::SQLite3::Version.to_i.should eql(3044000)
    Amalgalite::SQLite3::Version.runtime_version_number.should eql(3044000)

    Amalgalite::SQLite3::Version::MAJOR.should eql(3)
    Amalgalite::SQLite3::Version::MINOR.should eql(44)
    Amalgalite::SQLite3::Version::RELEASE.should eql(0)
    expect(Amalgalite::SQLite3::Version.to_a.size).to eql(3)

    Amalgalite::SQLite3::Version.compiled_version.should be == "3.44.0"
    Amalgalite::SQLite3::Version.compiled_version_number.should be == 3044000
    Amalgalite::SQLite3::Version.compiled_matches_runtime?.should be == true
  end

  it "should have the sqlite3 source id" do
    source_id = "2023-11-01 11:23:50 17129ba1ff7f0daf37100ee82d507aef7827cf38de1866e2633096ae6ad81301"
    Amalgalite::SQLite3::Version.compiled_source_id.should be == source_id
    Amalgalite::SQLite3::Version.runtime_source_id.should be == source_id
  end
end
