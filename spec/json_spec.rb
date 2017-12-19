require 'spec_helper'
require 'amalgalite/sqlite3'
require 'rbconfig'

describe "Amalgalite handles the JSON extension" do
  it "can parse a `json_each` call" do
    db = Amalgalite::Database.new( ":memory:" )
    values = %w[ a b c d e f g ]
    db.execute("CREATE TABLE jtest(id, json)")
    db.execute("INSERT INTO jtest(id, json) values (1, json($json))", { "$json" => values })
    rows = db.execute("SELECT jtest.id as i, value as v FROM jtest, json_each(jtest.json)")

    rows.size.should eq(values.size)
  end

  it "can return a proper json column" do
    db = Amalgalite::Database.new( ":memory:" )
    values = %w[ a b c d e f g ]
    db.execute("CREATE TABLE jtest(id INTEGER, json JSON)")
    db.execute("INSERT INTO jtest(id, json) values (1, json($json))", { "$json" => values })

    db.execute("select * from jtest")
  end
end
