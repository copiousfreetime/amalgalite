require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper.rb"))
require 'amalgalite/sqlite3'
require 'rbconfig'

describe "Amalgalite::SQLite3::Status" do
  it "knows how much memory it has used" do
    Amalgalite::SQLite3.status.memory_used.current.should >= 0
    Amalgalite::SQLite3.status.memory_used.highwater.should >= 0
  end

  it "can reset the highwater value" do
    before = Amalgalite::SQLite3.status.memory_used.highwater
    Amalgalite::SQLite3.status.memory_used.reset!
    Amalgalite::SQLite3.status.memory_used.highwater.should > 0
    after = Amalgalite::SQLite3.status.memory_used.highwater
    after.should_not eql(before)
  end
end
