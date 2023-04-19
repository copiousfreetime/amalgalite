require 'spec_helper'
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    expect(Amalgalite::SQLite3::VERSION).to match(/\d+\.\d+\.\d+/)
    expect(Amalgalite::SQLite3::Version.to_s).to match( /\d+\.\d+\.\d+/ )
    expect(Amalgalite::SQLite3::Version.runtime_version).to match( /\d+\.\d+\.\d+/ )

    Amalgalite::SQLite3::Version.to_i.should eql(3041002)
    Amalgalite::SQLite3::Version.runtime_version_number.should eql(3041002)

    Amalgalite::SQLite3::Version::MAJOR.should eql(3)
    Amalgalite::SQLite3::Version::MINOR.should eql(41)
    Amalgalite::SQLite3::Version::RELEASE.should eql(2)
    expect(Amalgalite::SQLite3::Version.to_a.size).to eql(3)

    Amalgalite::SQLite3::Version.compiled_version.should be == "3.41.2"
    Amalgalite::SQLite3::Version.compiled_version_number.should be == 3041002
    Amalgalite::SQLite3::Version.compiled_matches_runtime?.should be == true
  end

  it "should have the sqlite3 source id" do
    source_id = "2023-03-22 11:56:21 0d1fc92f94cb6b76bffe3ec34d69cffde2924203304e8ffc4155597af0c191da"
    Amalgalite::SQLite3::Version.compiled_source_id.should be == source_id
    Amalgalite::SQLite3::Version.runtime_source_id.should be == source_id
  end
end
