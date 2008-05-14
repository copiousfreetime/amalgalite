require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'

describe Amalgalite::Statement do
  before(:each) do
    @db_name = "test.db"
    @db = Amalgalite::Database.new( @db_name )
  end

  after(:each) do
    @db.close
    File.unlink @db_name if File.exist?( @db_name )
  end

  it "a statement has a copy of the sql it was prepared with" do
    stmt = @db.prepare( "SELECT strftime('%Y-%m-%d %H:%M:%S', 'now')")
    stmt.sql.should == "SELECT strftime('%Y-%m-%d %H:%M:%S', 'now')"
    stmt.close
  end

end
