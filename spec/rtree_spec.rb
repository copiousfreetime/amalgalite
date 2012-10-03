require File.expand_path( File.join( File.dirname(__FILE__), 'spec_helper'))
#
# Example from http://sqlite.org/rtree.html
#
describe "SQLite3 R*Tree extension" do
  before( :each ) do
    @db = Amalgalite::Database.new( ":memory:" )
    x = @db.execute_batch <<-sql
    CREATE VIRTUAL TABLE demo_index USING rtree(
       id,              -- Integer primary key
       minX, maxX,      -- Minimum and maximum X coordinate
       minY, maxY       -- Minimum and maximum Y coordinate
    );
    -- 
    INSERT INTO demo_index VALUES(
        1,                   -- Primary key
        -80.7749, -80.7747,  -- Longitude range
        30.3776, 30.3778     -- Latitude range
    );
    INSERT INTO demo_index VALUES(
        2,
        -81.0, -79.6,
        35.0, 36.2
    );
    sql
    x.should == 3
  end

  after( :each ) do
    @db.close
  end

  it "has 2 rows" do
    r = @db.first_value_from( "SELECT count(*) FROM demo_index")
    r.should == 2
  end

  it "queries normally" do
    r = @db.execute "SELECT * FROM demo_index WHERE id=1;"
    r.size.should be == 1
    row = r.first
    row['id'].should be == 1
  end

  it "does a 'contained within' query" do
    r = @db.execute <<-sql
    SELECT id FROM demo_index
     WHERE minX>=-81.08 AND maxX<=-80.58
       AND minY>=30.00  AND maxY<=30.44;
    sql

    r.size.should be == 1
    r.first['id'].should be == 1
  end

  it "does an 'overlapping' query" do
    r = @db.execute <<-sql
    SELECT id FROM demo_index
     WHERE maxX>=-81.08 AND minX<=-80.58
       AND maxY>=30.00  AND minY<=35.44;
    sql
    r.size.should == 2
  end
end

