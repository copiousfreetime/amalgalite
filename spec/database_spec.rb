require 'rubygems'
require 'spec'
require File.expand_path( File.join( File.dirname(__FILE__), 'spec_helper'))

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'
require 'amalgalite/taps/io'
require 'amalgalite/taps/console'
require 'amalgalite/database'

describe Amalgalite::Database do
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

  it "can create a new database" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.instance_of?(Amalgalite::Database) 
    db.api.instance_of?(Amalgalite::SQLite3::Database) 
    File.exist?( SpecInfo.test_db ).should == true
  end

  it "creates a new UTF-8 database (need exec to check pragma encoding)" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute_batch( @schema );
    db.should_not be_utf16
    db.encoding.should == "UTF-8"
  end

  it "creates a new UTF-16 database (need exec to check pragma encoding)" 

  it "raises an error if the file does not exist and the database is opened with a non-create mode" do
    lambda { Amalgalite::Database.new( SpecInfo.test_db, "r") }.should raise_error(Amalgalite::SQLite3::Error)
    lambda { Amalgalite::Database.new( SpecInfo.test_db, "r+") }.should raise_error(Amalgalite::SQLite3::Error)
  end

  it "raises an error if an invalid mode is used" do
    lambda { Amalgalite::Database.new( SpecInfo.test_db, "b+" ) }.should raise_error(Amalgalite::Database::InvalidModeError)
  end

  it "can be in autocommit mode, and is by default" do
    @iso_db.autocommit?.should == true
  end

  it "reports false for autocommit? when inside a transaction" do
    @iso_db.execute(" BEGIN ")
    @iso_db.autocommit?.should == false
    @iso_db.in_transaction?.should == true
    @iso_db.execute(" COMMIT")
    @iso_db.in_transaction?.should == false
  end

  it "prepares a statment" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    stmt = db.prepare("SELECT datetime()")
    stmt.instance_of?(Amalgalite::Statement)
    stmt.api.instance_of?(Amalgalite::SQLite3::Statement)
  end

  it "raises an error on invalid syntax when preparing a bad sql statement" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.prepare("SELECT nothing FROM stuf") }.should raise_error(Amalgalite::SQLite3::Error)
  end

  it "closes normally" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.close }.should_not raise_error( Amalgalite::SQLite3::Error )
  end

  it "returns the id of the last inserted row" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.last_insert_rowid.should == 0
  end

  it "is in autocommit mode by default" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.should be_autocommit
  end

  it "report the number of rows changed with an insert" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute_batch <<-sql
      CREATE TABLE t1( x );
      INSERT INTO t1( x ) values ( 1 );
      INSERT INTO t1( x ) values ( 2 );
      INSERT INTO t1( x ) values ( 3 );
    sql

    db.row_changes.should == 1
    db.total_changes.should == 3
    db.close
  end

  it "reports the number of rows deleted" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute_batch <<-sql
      CREATE TABLE t1( x );
      INSERT INTO t1( x ) values ( 1 );
      INSERT INTO t1( x ) values ( 2 );
      INSERT INTO t1( x ) values ( 3 );
      DELETE FROM t1 where x < 3;
    sql
    db.row_changes.should == 2
    db.close
  end

  it "can immediately execute an sql statement " do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute( "CREATE TABLE t1( x, y, z )" ).should be_empty
  end

  it "can execute a batch of commands" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    db.execute_batch( @schema ).should == 5
  end

  it "traces the execution of code" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    sql = "CREATE TABLE trace_test( x, y, z)"
    s = db.trace_tap = ::Amalgalite::Taps::StringIO.new
    db.execute( sql )
    db.trace_tap.string.should== "registered as trace tap\n#{sql}\n"
    db.trace_tap = nil
    s.string.should== "registered as trace tap\n#{sql}\nunregistered as trace tap\n"
  end

  it "raises an exception if the wrong type of object is used for tracing" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.trace_tap = Object.new }.should raise_error(Amalgalite::Error)
  end

  it "raises an exception if the wrong type of object is used for profile" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    lambda { db.profile_tap = Object.new }.should raise_error(Amalgalite::Error)
  end

  it "profiles the execution of code" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    s = db.profile_tap = ::Amalgalite::Taps::StringIO.new
    db.execute_batch( @schema )
    db.profile_tap.samplers.size.should == 6
    db.profile_tap = nil
    s.string.should =~ /unregistered as profile tap/m
  end

  it "#execute yields each row when called with a block" do
    count = 0
    @iso_db.execute( "SELECT * FROM country LIMIT 10") do |row|
      count += 1
    end
    count.should == 10
  end

  it "#pragma yields each row when called with a block" do
    count = 0
    @iso_db.pragma( "index_info( subcountry_country )" ) do |row|
      count += 1
    end
    count.should == 1
  end

  it "can use something that responds to 'write' as a tap" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    s2 = db.trace_tap   = StringIO.new
    s2.string.should == "registered as trace tap"
  end

  it "can clear all registered taps" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    s = db.profile_tap = ::Amalgalite::Taps::StringIO.new
    db.trace_tap = s
    db.execute_batch( @schema )
    db.profile_tap.samplers.size.should == 6
    db.clear_taps!
    s.string.should =~ /unregistered as trace tap/m
    s.string.should =~ /unregistered as profile tap/m
  end

  it "allows nested transactions even if SQLite under the covers does not" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    r = db.transaction do |db2|
      r2 = db.transaction { 42 }
      r2.should == 42
      r2
    end
    r.should == 42
  end

  it "returns the result of the transaction when a block is yielded" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    (db.transaction { 42 }).should == 42
  end

  it "#reload_schema!" do
    @iso_db = Amalgalite::Database.new( SpecInfo.make_iso_db )
    schema = @iso_db.schema
    schema.instance_of?( Amalgalite::Schema ).should == true
    s2 = @iso_db.reload_schema!
    s2.object_id.should_not == schema.object_id
  end

  it "can rollback a transaction" do
    @iso_db.transaction 
    r = @iso_db.execute("SELECT count(1) as cnt FROM country");
    r.first['cnt'].should == 242
    @iso_db.execute("DELETE FROM country")
    r = @iso_db.execute("SELECT count(1) as cnt FROM country");
    r.first['cnt'].should == 0
    @iso_db.rollback

    r = @iso_db.execute("SELECT count(1) as cnt FROM country");
    r.first['cnt'].should == 242
  end

  it "rolls back if an exception happens during a transaction block" do
    begin
      @iso_db.transaction do |db|
        r = db.execute("SELECT count(1) as cnt FROM country");
        r.first['cnt'].should == 242
        db.execute("DELETE FROM country")
        db.in_transaction?.should == true
        raise "testing rollback"
      end
    rescue => e
      @iso_db.in_transaction?.should == false
      @iso_db.execute("SELECT count(1) as cnt FROM country").first['cnt'].should == 242
    end
  end

  describe "#define_function" do
   it "does not allow mixing of arbitrary and mandatory arguments to an SQL function" do
      class FunctionTest2 < ::Amalgalite::Function
        def initialize
          super( 'ftest2', -2 )
        end
        def call( a, *args ); end
      end
      lambda { @iso_db.define_function("ftest2", FunctionTest2.new ) }.should raise_error( ::Amalgalite::Database::FunctionError )
    end

    it "does not allow outrageous arity" do
      class FunctionTest3 < ::Amalgalite::Function
        def initialize
          super( 'ftest3', 128 )
        end
        def call( *args) ; end
      end
      lambda { @iso_db.define_function("ftest3", FunctionTest3.new ) }.should raise_error( ::Amalgalite::SQLite3::Error )
    end

 end

  describe "#remove_function" do
    it "unregisters a single function by name and arity" do
      @iso_db.define_function( "rtest" ) do
        "rtest called"
      end
      @iso_db.functions.size.should == 1 

      r = @iso_db.execute( "select rtest() AS r" )
      r.first['r'].should == "rtest called"
      @iso_db.remove_function("rtest", -1)
      lambda { @iso_db.execute( "select rtest() as r" )}.should raise_error( ::Amalgalite::SQLite3::Error, /no such function: rtest/ )
      @iso_db.functions.size.should == 0
    end

    it "unregisters a function by instances" do
      class FunctionTest5 < ::Amalgalite::Function
        def initialize
          super( 'ftest5', 0)
        end
        def call( *args) "ftest5 called"; end
      end
      @iso_db.define_function("ftest5", FunctionTest5.new )
      @iso_db.functions.size.should == 1
      r = @iso_db.execute( "select ftest5() AS r" )
      r.first['r'].should == "ftest5 called"
      @iso_db.remove_function("ftest5", FunctionTest5.new )
      lambda { @iso_db.execute( "select ftest5() as r" )}.should raise_error( ::Amalgalite::SQLite3::Error, /no such function: ftest5/ )
      @iso_db.functions.size.should == 0
    end

    it "unregisters all functions with the same name" do
      @iso_db.function( "rtest" ) do |x|
        "rtest #{x} called"
      end

      @iso_db.function( "rtest" ) do ||
        "rtest/0 called"
      end

      @iso_db.functions.size.should == 2
      r = @iso_db.execute( "select rtest(1) AS r")
      r.first['r'].should == "rtest 1 called"
      r = @iso_db.execute( "select rtest() AS r")
      r.first['r'].should == "rtest/0 called"
      @iso_db.remove_function( 'rtest' )
      lambda {  @iso_db.execute( "select rtest(1) AS r") }.should raise_error( ::Amalgalite::SQLite3::Error )
      lambda {  @iso_db.execute( "select rtest() AS r")  }.should raise_error( ::Amalgalite::SQLite3::Error )
      @iso_db.functions.size.should == 0
    end
  end

  it "can interrupt another thread that is also running in this database" do
    had_error = nil 
    executions = 0
    other = Thread.new( @iso_db ) do |db|
      loop do
        begin
          db.execute("select count(id) from country")
          executions += 1
        rescue => e
          had_error = e
          break
        end
      end
    end

    rudeness = Thread.new( @iso_db ) do |db|
      sleep 0.05
      @iso_db.interrupt!
    end

    rudeness.join

    executions.should > 10
    had_error.should be_an_instance_of( ::Amalgalite::SQLite3::Error )
    had_error.message.should =~ / interrupted/
  end

  it "savepoints are considered 'in_transaction'" do
    @iso_db.savepoint( 'test1' ) do |db|
      db.should be_in_transaction
    end
  end

  it "releases a savepoint" do
    us_sub = @iso_db.execute( "select count(1) as cnt from subcountry where country = 'US'" ).first['cnt']
    us_sub.should == 57
    other_sub = @iso_db.execute( "select count(1) as cnt from subcountry where country != 'US'" ).first['cnt']

    @iso_db.transaction
    @iso_db.savepoint( "t1" ) do |s|
      s.execute("DELETE FROM subcountry where country = 'US'")
    end

    all_sub = @iso_db.execute("SELECT count(*) as cnt from subcountry").first['cnt']

    all_sub.should == other_sub;
    @iso_db.rollback
    all_sub = @iso_db.execute("SELECT count(*) as cnt from subcountry").first['cnt']
    all_sub.should == ( us_sub + other_sub )

  end
  it "rolls back a savepoint" do
    all_sub = @iso_db.execute("SELECT count(*) as cnt from subcountry").first['cnt']
    lambda {
      @iso_db.savepoint( "t1" ) do |s|
        s.execute("DELETE FROM subcountry where country = 'US'")
        raise "sample error"
      end
    }.should raise_error( StandardError, /sample error/ )

    @iso_db.execute("SELECT count(*) as cnt from subcountry").first['cnt'].should == all_sub
  end

  it "rolling back the outermost savepoint is still 'in_transaction'" do
    @iso_db.savepoint( "t1" )
    @iso_db.execute("DELETE FROM subcountry where country = 'US'")
    @iso_db.rollback_to( "t1" )
    @iso_db.should be_in_transaction
    @iso_db.rollback
    @iso_db.should_not be_in_transaction
  end

  it "can escape quoted strings" do
    @iso_db.escape( "It's a happy day!" ).should == "It''s a happy day!"
  end

  it "can quote and escape single quoted strings" do
    @iso_db.quote( "It's a happy day!" ).should == "'It''s a happy day!'"
  end

  it "can escape a symbol" do
    @iso_db.escape( :stuff ).should == "stuff"
  end
  
  it "can quote a symbol" do
    @iso_db.quote( :stuff ).should == "'stuff'"
  end

  it "returns the first row of results as a convenience" do
    row =  @iso_db.first_row_from("SELECT c.name, c.two_letter, count(*) AS count 
                                     FROM country c
                                     JOIN subcountry sc
                                       ON c.two_letter  = sc.country 
                                 GROUP BY c.name, c.two_letter
                                 ORDER BY count DESC")
    row.length.should == 3
    row[0].should == "United Kingdom"
    row[1].should == "GB"
    row[2].should == 232
    row['name'].should == "United Kingdom"
    row['two_letter'].should == "GB"
    row['count'].should == 232
  end

  it "returns the first value of results as a conveinience" do
    val = @iso_db.first_value_from("SELECT count(*) from subcountry ")
    val.should == 3995
  end

end
