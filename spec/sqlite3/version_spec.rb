require 'spec_helper'
require 'amalgalite/sqlite3/version'

describe "Amalgalite::SQLite3::Version" do
  it "should have the sqlite3 version" do
    expect(Amalgalite::SQLite3::VERSION).to match(/\d+\.\d+\.\d+/)
    expect(Amalgalite::SQLite3::Version.to_s).to match( /\d+\.\d+\.\d+/ )
    expect(Amalgalite::SQLite3::Version.runtime_version).to match( /\d+\.\d+\.\d+/ )

    Amalgalite::SQLite3::Version.to_i.should eql(3021000)
    Amalgalite::SQLite3::Version.runtime_version_number.should eql(3021000)

    Amalgalite::SQLite3::Version::MAJOR.should eql(3)
    Amalgalite::SQLite3::Version::MINOR.should eql(21)
    Amalgalite::SQLite3::Version::RELEASE.should eql(0)
    expect(Amalgalite::SQLite3::Version.to_a.size).to eql(3)

    Amalgalite::SQLite3::Version.compiled_version.should be == "3.21.0"
    Amalgalite::SQLite3::Version.compiled_version_number.should be == 3021000
    Amalgalite::SQLite3::Version.compiled_matches_runtime?.should be == true
  end

  it "should have the sqlite3 source id" do
    source_id = "2017-10-24 18:55:49 1a584e499906b5c87ec7d43d4abce641fdf017c42125b083109bc77c4de48827"
    Amalgalite::SQLite3::Version.compiled_source_id.should be == source_id
    Amalgalite::SQLite3::Version.runtime_source_id.should be == source_id
  end
end
