require 'rubygems'
require 'spec'

require File.expand_path( File.join( File.dirname( __FILE__ ), "spec_helper.rb" ) )

require 'amalgalite'
require 'amalgalite/database'

class AggregateTest1 < ::Amalgalite::Aggregate
  def initialize
    @name = 'atest1'
    @arity = -1
    @count = 0
  end
  def step( *args )
    @count += 1
  end
  def finalize
    return @count
  end
end


describe "Aggregate SQL Functions" do

  before(:each) do
    @schema = IO.read( SpecInfo.test_schema_file )
    @iso_db_file = SpecInfo.make_iso_db
    @iso_db = Amalgalite::Database.new( SpecInfo.make_iso_db )
  end

  after(:each) do
    File.unlink SpecInfo.test_db if File.exist?( SpecInfo.test_db )
    @iso_db.close
    File.unlink @iso_db_file if File.exist?( @iso_db_file )
  end


  it "must have a finalize method implemented" do
    ag = ::Amalgalite::Aggregate.new
    lambda { ag.finalize }.should raise_error( NotImplementedError, /Aggregate#finalize must be implemented/ )
  end

  it "can define a custom SQL aggregate as a class with N params" do
    @iso_db.define_aggregate("atest1", AggregateTest1 )
    r = @iso_db.execute("SELECT atest1(id,name) as a, count(*) as c FROM country")
    r.first['a'].should eql(r.first['c'])
    r.first['a'].should eql(242)
  end

  it "can remove a custom SQL aggregate by class" do
    @iso_db.define_aggregate("atest1", AggregateTest1 )
    @iso_db.aggregates.size.should eql(1)
    r = @iso_db.execute("SELECT atest1(id,name) as a, count(*) as c FROM country")
    r.first['a'].should eql(r.first['c'])
    r.first['a'].should eql(242)
    @iso_db.remove_aggregate( "atest1", AggregateTest1 )
    @iso_db.aggregates.size.should eql(0)
    lambda{ @iso_db.execute("SELECT atest1(id,name) as a, count(*) as c FROM country") }.should raise_error(::Amalgalite::SQLite3::Error, /no such function: atest1/ )
  end

  it "can remove a custom SQL aggregate by arity" do
    @iso_db.define_aggregate("atest1", AggregateTest1 )
    @iso_db.aggregates.size.should eql(1)
    r = @iso_db.execute("SELECT atest1(id,name) as a, count(*) as c FROM country")
    r.first['a'].should eql(r.first['c'])
    r.first['a'].should eql(242)
    @iso_db.remove_aggregate( "atest1", -1)
    @iso_db.aggregates.size.should eql(0)
    lambda{ @iso_db.execute("SELECT atest1(id,name) as a, count(*) as c FROM country") }.should raise_error(::Amalgalite::SQLite3::Error, /no such function: atest1/ )
  end

  it "can remove all custom SQL aggregates with the same name" do
    class AT2 < AggregateTest1
      def arity() 1; end
    end
    @iso_db.define_aggregate("atest1", AggregateTest1 )
    @iso_db.define_aggregate("atest1", AT2)
    @iso_db.aggregates.size.should eql(2)
    r = @iso_db.execute("SELECT atest1(id,name) as a, atest1(id), count(*) as c FROM country")
    r.first['a'].should eql(r.first['c'])
    r.first['a'].should eql(242)
    @iso_db.remove_aggregate( "atest1" )
    @iso_db.aggregates.size.should eql(0)
    lambda{ @iso_db.execute("SELECT atest1(id,name) as a, count(*) as c FROM country") }.should raise_error(::Amalgalite::SQLite3::Error, /no such function: atest1/ )
  end



  it "does not allow mixing of arbitrary and mandatory arguments to an SQL function" do
    class AggregateTest2 < AggregateTest1
      def name() "atest2"; end
      def arity() -2; end
    end
    lambda { @iso_db.define_aggregate("atest2", AggregateTest2 ) }.should raise_error( ::Amalgalite::Database::AggregateError, 
                                                    /Use only mandatory or arbitrary parameters in an SQL Aggregate, not both/ )
  end

  it "does not allow outrageous arity" do
    class AggregateTest3 < AggregateTest1
      def name() "atest3"; end
      def arity() 128; end
    end
    lambda { @iso_db.define_aggregate("atest3", AggregateTest3 ) }.should raise_error( ::Amalgalite::SQLite3::Error, /SQLITE_ERROR .* Library used incorrectly/ )
  end

  it "does not allow registering a function which does not match the defined name " do
    class AggregateTest4 < AggregateTest1
      def name() "name_mismatch"; end
    end
    lambda { @iso_db.define_aggregate("atest4", AggregateTest4 ) }.should raise_error( ::Amalgalite::Database::AggregateError,
                                           /Aggregate implementation name 'name_mismatch' does not match defined name 'atest4'/)
  end

  it "handles an error being thrown during the step function" do
    class AggregateTest5 < AggregateTest1
      def initialize
        @name = "atest5"
        @arity = -1
        @count = 0
      end

      def step( *args )
        @count += 1
        if @count > 50 then
          raise "Stepwise error!" if @count > 50
        end
      end

    end

    @iso_db.define_aggregate( "atest5", AggregateTest5 )
    lambda { @iso_db.execute( "SELECT atest5(*) AS a FROM country" ) }.should raise_error( ::Amalgalite::SQLite3::Error, /Stepwise error!/ )
  end

  it "handles an error being thrown during the finalize function" do
    class AggregateTest6 < AggregateTest1
      def initialize
        @name = "atest6"
        @count = 0
        @arity = -1
      end
      def finalize
        raise "Finalize error!"
      end
    end
    @iso_db.define_aggregate( "atest6", AggregateTest6 )
    lambda { @iso_db.execute( "SELECT atest6(*) AS a FROM country" ) }.should raise_error( ::Amalgalite::SQLite3::Error, /Finalize error!/ )
  end

  it "handles an error being thrown during initialization in the C extension" do
    class AggregateTest7 < AggregateTest1
      @@instance_count = 0
      def initialize
        @name = "atest7"
        @count = 0
        @arity = -1
        if @@instance_count > 0 then
          raise "Initialization error!"
        else
          @@instance_count += 1
        end
      end
    end
    @iso_db.define_aggregate( "atest7", AggregateTest7 )
    lambda { @iso_db.execute( "SELECT atest7(*) AS a FROM country" ) }.should raise_error( ::Amalgalite::SQLite3::Error, /Initialization error!/ )
  end
end

