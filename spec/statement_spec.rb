require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'

describe Amalgalite::Statement do
  before(:each) do
    @db = Amalgalite::Database.new( SpecInfo.test_db )
    @schema_sql = IO.read( SpecInfo.test_schema_file )
    @iso_db_file = SpecInfo.make_iso_db
    @iso_db = Amalgalite::Database.new( SpecInfo.make_iso_db )
  end

  after(:each) do
    @db.close
    File.unlink SpecInfo.test_db if File.exist?( SpecInfo.test_db )
    
    @iso_db.close
    File.unlink @iso_db_file if File.exist?( @iso_db_file )
  end

  it "a statement has a copy of the sql it was prepared with" do
    stmt = @db.prepare( "SELECT strftime('%Y-%m-%d %H:%M:%S', 'now')")
    stmt.sql.should == "SELECT strftime('%Y-%m-%d %H:%M:%S', 'now')"
    stmt.close
  end

  it "steps through results" do
    now = Time.new.utc.strftime("%Y-%m-%d %H:%M")
    @db.prepare( "SELECT strftime('%Y-%m-%d %H:%M', 'now') as now") do |stmt|
      stmt.should_not == nil
      stmt.each do |row|
        row['now'].should == now
      end
    end
  end

  it "can prepare a statement without a block" do
    stmt = @iso_db.prepare("SELECT * FROM country WHERE two_letter = :two") 
    rs = stmt.execute( ":two" => "JP" )
    rs.size.should == 1
    stmt.close
  end

  it "knows how many parameters are in the statement" do
    @iso_db.prepare("SELECT * FROM country WHERE two_letter = :two") do |stmt|
      stmt.check_parameter_count!( 1 ).should == 1
    end
  end

  it "raises an error if there are not enough parameters are passed in a statement" do
    @iso_db.prepare("SELECT * FROM country WHERE two_letter = :two") do |stmt|
      lambda{ stmt.execute }.should raise_error( Amalgalite::Error )
    end
  end


  it "can run a query with a named parameter" do
    @iso_db.prepare("SELECT * FROM country WHERE two_letter = :two") do |stmt|
      all_rows = stmt.execute( ":two" => "JP" )
      all_rows.size.should == 1
      all_rows.first['name'].should == "Japan"
    end
  end

  it "it can execute a query with a named parameter and yield the rows" do 
    @iso_db.prepare("SELECT * FROM country WHERE id = @id ORDER BY name") do |stmt|
      rows = []
      stmt.execute( "@id" => 891 ) do |row|
        rows << row
      end
      rows.size.should == 2
      rows.last['name'].should == "Yugoslavia"
      rows.first['two_letter'].should == "CS"
    end
  end


  it "binds a integer variable correctly" do
    @iso_db.prepare("SELECT * FROM country WHERE id = ? ORDER BY name ") do |stmt|
      all_rows = stmt.execute( 891 )
      all_rows.size.should == 2
      all_rows.last['name'].should == "Yugoslavia"
      all_rows.first['two_letter'].should == "CS"
    end
  end

  it "raises and error if an invaliding binding is attempted" do 
    @iso_db.prepare("SELECT * FROM country WHERE id = :somevar ORDER BY name ") do |stmt|
      lambda{ stmt.execute( "blah" => 42 ) }.should raise_error(Amalgalite::Error)
    end
  end

  it "can reset the statement to the state it was before executing" do
    stmt = @iso_db.prepare("SELECT * FROM country WHERE id = :somevar ORDER BY name ") 
    stmt.reset_and_clear_bindings!
    stmt.close
  end


  it "can execute a single sql command and say if there is remaining sql to execute" do
    db = Amalgalite::Database.new( SpecInfo.test_db )
    stmt = @db.prepare( @schema_sql )
    stmt.execute
    stmt.remaining_sql.size.should > 0
    stmt.close
  end
end
