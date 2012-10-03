require 'spec_helper'

require 'amalgalite'
require 'amalgalite/schema'

describe Amalgalite::Schema do

  it "loads the schema of a database" do
    schema = @iso_db.schema
    schema.load_tables
    schema.tables.size.should eql(2)
  end

  it "loads the views in the database" do
    s = @iso_db.schema
    sql = "CREATE VIEW v1 AS SELECT c.name, c.two_letter, s.name, s.subdivision FROM country AS c JOIN subcountry AS s ON c.two_letter = s.country"
    @iso_db.execute( sql )
    s.dirty?.should be == true
    @iso_db.schema.load_views
    @iso_db.schema.views.size.should eql(1)
    @iso_db.schema.views["v1"].sql.should eql(sql)
  end

  it "removes quotes from around default values in columns" do
    s = @iso_db.schema
    sql = "CREATE TABLE t1( d1 default 't' )"
    @iso_db.execute( sql )
    s.dirty?.should be == true
    tt = @iso_db.schema.tables['t1']
    tt.columns['d1'].default_value.should be == "t"
  end

  it "loads the tables and columns" do
    ct = @iso_db.schema.tables['country']
    ct.name.should eql("country")
    ct.columns.size.should eql(3)
    ct.indexes.size.should eql(2)
    ct.column_names.should eql(%w[ name two_letter id ])
    @iso_db.schema.tables.size.should eql(2)


    ct.columns['two_letter'].should be_primary_key
    ct.columns['two_letter'].declared_data_type.should eql("TEXT")
    ct.columns['name'].should_not be_nullable
    ct.columns['name'].should be_not_null_constraint
    ct.columns['name'].should_not be_has_default_value
    ct.columns['id'].should_not be_auto_increment
  end

  it "knows what the primary key of a table is" do
    ct = @iso_db.schema.tables['country']
    ct.primary_key.should == [ ct.columns['two_letter'] ]
  end

  it "knows the primary key of a table even without an explicity unique index" do
    s = @iso_db.schema
    sql = "CREATE TABLE u( id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , other text )"
    @iso_db.execute( sql )
    s.dirty?.should be == true
    ut = @iso_db.schema.tables['u']
    ut.primary_key.should == [ ut.columns['id'] ]
  end

  it "knows the primary key of a temporary table" do
    @iso_db.execute "CREATE TEMPORARY TABLE tt( a, b INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, c )"
    tt = @iso_db.schema.tables[ 'tt' ]
    tt.primary_key.should == [ tt.columns['b'] ]
  end

  it "knows what the primary key of a table is when it is a multiple column primary key" do
    sql = "CREATE TABLE m ( id1, id2, PRIMARY KEY (id2, id1) )"
    s = @iso_db.schema
    @iso_db.execute( sql )
    s.dirty?.should be == true
    mt = @iso_db.schema.tables['m']
    mt.primary_key.should == [ mt.columns['id2'], mt.columns['id1'] ]
  end

  it "loads the indexes" do
    c = @iso_db.schema.tables['country']
    c.indexes.size.should eql(2)
    c.indexes['country_name'].columns.size.should eql(1)
    c.indexes['country_name'].should_not be_unique
    c.indexes['country_name'].sequence_number.should eql(0)
    c.indexes['country_name'].columns.first.should eql(@iso_db.schema.tables['country'].columns['name'])
    c.indexes['sqlite_autoindex_country_1'].should be_unique

    subc = @iso_db.schema.tables['subcountry']
    subc.indexes.size.should eql(3)
    subc.indexes['subcountry_country'].columns.first.should eql(@iso_db.schema.tables['subcountry'].columns['country'])
  end

  it "knows the schema is dirty when a table is created" do
    s = @iso_db.schema
    s.tables['country']
    s.dirty?.should be == false
    @iso_db.execute( "create table x1( a, b )" )
    s.dirty?.should be == true
  end

  it "knows the schema is dirty when a table is dropped" do
    s = @iso_db.schema
    s.tables['country']
    @iso_db.execute( "create table x1( a, b )" )
    s.dirty?.should be == true

    @iso_db.schema.load_schema!
    s = @iso_db.schema

    s.dirty?.should be == false
    @iso_db.execute("drop table x1")
    s.dirty?.should be == true
  end

  it "knows if a temporary table exists" do
    @iso_db.execute "CREATE TEMPORARY TABLE tt(a,b,c)"
    @iso_db.schema.tables.keys.include?('tt').should be == true
    @iso_db.schema.tables['tt'].temporary?.should be == true
  end

  it "sees that temporary tables shadow real tables" do
    @iso_db.execute "CREATE TABLE tt(x)"
    @iso_db.schema.tables['tt'].temporary?.should be == false
    @iso_db.execute "CREATE TEMP TABLE tt(a,b,c)"
    @iso_db.schema.tables['tt'].temporary?.should be == true
    @iso_db.execute "DROP TABLE tt"
    @iso_db.schema.tables['tt'].temporary?.should be == false
    @iso_db.schema.tables['tt'].columns.size.should be == 1
  end

end
