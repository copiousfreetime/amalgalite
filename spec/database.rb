require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'

describe Amalgalite::Database do
  before(:each) do
    @db_name = "test.db"
  end

  after(:each) do
    File.unlink @db_name
  end

  it "can create a new database" do
    db = Amalgalite::Database.new( @db_name )
    db != nil
  end
end

