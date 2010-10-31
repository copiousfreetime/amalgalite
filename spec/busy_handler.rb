require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper.rb' ) )

class BusyHandlerTest < Amalgalite::BusyHandler
  attr_accessor :call_count
  def initialize( max = 5 )
    @max = max
    @call_count = 0
  end

  def call( c )
    @call_count += 1
    if call_count >= @max then
      return false
    end
    return true
  end
end

describe "Busy Handlers" do
  before(:each) do
    @read_db = Amalgalite::Database.new( @iso_db_path )
    @write_db = Amalgalite::Database.new( @iso_db_path )
  end

  after(:each) do
    @write_db.close
    @read_db.close
  end

  it "raises NotImplemented if #call is not overwritten" do
    bh = ::Amalgalite::BusyHandler.new
    lambda { bh.call( 42 ) }.should raise_error( ::NotImplementedError, /The busy handler call\(N\) method must be implemented/ )
  end

  it "can be registered as block" do
    call_count = 0
    @write_db.busy_handler do |x|
      call_count = x
      if call_count >= 20 then
        false
      else
        true
      end
    end

    # put a read lock on the database
    @read_db.transaction( "DEFERRED" )

    # put a read lock on the database, but want to go to an exclusive
    @write_db.transaction( "IMMEDIATE" )

    # do a read operation
    @read_db.execute("SELECT count(*) FROM subcountry")

    # attempt to do a write operation and commit it
    @write_db.execute("DELETE FROM subcountry")
    lambda { @write_db.execute("COMMIT"); }.should raise_error( ::Amalgalite::SQLite3::Error, /database is locked/ )
    call_count.should == 20
  end

  it "can be registered as lambda" do
    call_count = 0
    callable = lambda do |x|
      call_count = x
      if call_count >= 40 then
        false
      else
        true
      end
    end

    @write_db.busy_handler( callable )

    # put a read lock on the database
    @read_db.transaction( "DEFERRED" )

    # put a read lock on the database, but want to go to an exclusive
    @write_db.transaction( "IMMEDIATE" )

    # do a read operation
    @read_db.execute("SELECT count(*) FROM subcountry")

    # attempt to do a write operation and commit it
    @write_db.execute("DELETE FROM subcountry")
    lambda { @write_db.execute("COMMIT"); }.should raise_error( ::Amalgalite::SQLite3::Error, /database is locked/ )
    call_count.should == 40
  end

  it "can be registered as a class" do
    h = BusyHandlerTest.new( 10 )
    @write_db.busy_handler( h )

    # put a read lock on the database
    @read_db.transaction( "DEFERRED" )

    # put a read lock on the database, but want to go to an exclusive
    @write_db.transaction( "IMMEDIATE" )

    # do a read operation
    @read_db.execute("SELECT count(*) FROM subcountry")

    # attempt to do a write operation and commit it
    @write_db.execute("DELETE FROM subcountry")
    lambda { @write_db.execute("COMMIT"); }.should raise_error( ::Amalgalite::SQLite3::Error, /database is locked/ )
    h.call_count.should == 10
  end

  it "has a default timeout class available " do
    to = ::Amalgalite::BusyTimeout.new( 5, 10 ) 
    @write_db.busy_handler( to )

    # put a read lock on the database
    @read_db.transaction( "DEFERRED" )

    # put a read lock on the database, but want to go to an exclusive
    @write_db.transaction( "IMMEDIATE" )

    # do a read operation
    @read_db.execute("SELECT count(*) FROM subcountry")

    # attempt to do a write operation and commit it
    @write_db.execute("DELETE FROM subcountry")
    before = Time.now
    lambda { @write_db.execute("COMMIT"); }.should raise_error( ::Amalgalite::SQLite3::Error, /database is locked/ )
    after = Time.now
    to.call_count.should > 5
    (after - before).should > 0.05
  end

  it "cannot register a block with the wrong arity" do
    lambda do 
      @write_db.define_busy_handler { |x,y| puts "What!" }
    end.should raise_error( ::Amalgalite::Database::BusyHandlerError, /A busy handler expects 1 and only 1 argument/ )
  end

  it "can remove a busy handler" do
    bht = BusyHandlerTest.new

    @write_db.busy_handler( bht )

    # put a read lock on the database
    @read_db.transaction( "DEFERRED" )

    # put a read lock on the database, but want to go to an exclusive
    @write_db.transaction( "IMMEDIATE" )

    # do a read operation
    @read_db.execute("SELECT count(*) FROM subcountry")

    # attempt to do a write operation and commit it
    @write_db.execute("DELETE FROM subcountry")
    @write_db.remove_busy_handler
    lambda { @write_db.execute("COMMIT"); }.should raise_error( ::Amalgalite::SQLite3::Error, /database is locked/ )
    bht.call_count.should == 0
  end

end
