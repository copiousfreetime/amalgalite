require 'spec_helper'

class PH < ::Amalgalite::ProgressHandler
  attr_reader :call_count
  def initialize( max = nil )
    @call_count = 0
    @max = max
  end

  def call
    @call_count += 1
    if @max && ( @call_count >= @max ) then
      return false
    end
    return true
  end
end

def query_thread( database )
  Thread.new( database ) do |db|
    begin
      db.execute("select count(id) from country")
    rescue => e
      Thread.current[:exception] = e
    end
  end
end

describe "Progress Handlers" do

  it "raises NotImplemented if #call is not overwritten" do
    bh = ::Amalgalite::ProgressHandler.new
    lambda { bh.call }.should raise_error( ::NotImplementedError, /The progress handler call\(\) method must be implemented/ )
  end

  it "can be registered as block" do
    call_count = 0
    @iso_db.progress_handler( 50 ) do ||
      call_count += 1
    true
    end
    qt = query_thread( @iso_db )
    qt.join
    call_count.should > 10
  end

  it "can be registered as lambda" do
    call_count = 0
    callable = lambda { || call_count += 1; true }
    @iso_db.progress_handler( 42, callable ) 
    qt = query_thread( @iso_db )
    qt.join
    call_count.should > 10
  end

  it "can be registered as a class" do
    ph = PH.new 
    @iso_db.progress_handler( 5, ph )
    qt = query_thread( @iso_db )
    qt.join
    ph.call_count.should > 100
  end

  it "behaves like #interrupt! if returning a false value" do
    ph = PH.new( 25 )
    @iso_db.progress_handler( 5, ph )
    qt = query_thread( @iso_db )
    qt.join
    ph.call_count.should eql(25)
    qt[:exception].should be_instance_of( ::Amalgalite::SQLite3::Error )
    @iso_db.api.last_error_code.should be == 9
    @iso_db.api.last_error_message.should  =~ /interrupted/
    qt[:exception].message.should =~ /interrupted/
  end

  it "cannot register a block with the wrong arity" do
    lambda do 
      @iso_db.define_progress_handler { |x,y| puts "What!" }
    end.should raise_error( ::Amalgalite::Database::ProgressHandlerError, /A progress handler expects 0 arguments, not 2/)
  end

  it "can remove a progress handler" do
    ph = PH.new 
    @iso_db.progress_handler( 5, ph )
    @iso_db.remove_progress_handler
    qt = query_thread( @iso_db )
    qt.join
    ph.call_count.should eql(0)
    qt[:exception].should be_nil
  end
end
