require 'spec_helper'
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    expect(Amalgalite::SQLite3::VERSION).to match(/\d+\.\d+\.\d+/)
    expect(Amalgalite::SQLite3::Version.to_s).to match( /\d+\.\d+\.\d+/ )
    expect(Amalgalite::SQLite3::Version.runtime_version).to match( /\d+\.\d+\.\d+/ )

    Amalgalite::SQLite3::Version.to_i.should eql(3038005)
    Amalgalite::SQLite3::Version.runtime_version_number.should eql(3038005)

    Amalgalite::SQLite3::Version::MAJOR.should eql(3)
    Amalgalite::SQLite3::Version::MINOR.should eql(38)
    Amalgalite::SQLite3::Version::RELEASE.should eql(5)
    expect(Amalgalite::SQLite3::Version.to_a.size).to eql(3)

    Amalgalite::SQLite3::Version.compiled_version.should be == "3.38.5"
    Amalgalite::SQLite3::Version.compiled_version_number.should be == 3038005
    Amalgalite::SQLite3::Version.compiled_matches_runtime?.should be == true
  end

  it "should have the sqlite3 source id" do
    source_id = "2022-05-06 15:25:27 78d9c993d404cdfaa7fdd2973fa1052e3da9f66215cff9c5540ebe55c407d9fe"
    Amalgalite::SQLite3::Version.compiled_source_id.should be == source_id
    Amalgalite::SQLite3::Version.runtime_source_id.should be == source_id
  end
end
