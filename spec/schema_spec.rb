require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'
require 'amalgalite/schema'

describe Amalgalite::Schema do
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

  it "loads the schema of a database" do
    schema = @iso_db.schema
    schema.load_tables
    schema.tables.size.should == 2
  end

  it "loads the views in the database" do
    sql = "CREATE VIEW v1 AS SELECT c.name, c.two_letter, s.name, s.subdivision FROM country AS c JOIN subcountry AS s ON c.two_letter = s.country"
    @iso_db.execute( sql )
    @iso_db.schema.load_views
    @iso_db.schema.views.size.should == 1
    @iso_db.schema.views["v1"].sql.should == sql
  end

  it "loads the tables and columns" do
    ct = @iso_db.schema.tables['country']
    ct.name.should == "country"
    ct.columns.size.should == 3
    ct.indexes.size.should == 2
    ct.column_names.should == %w[ name two_letter id ]
    @iso_db.schema.tables.size.should == 1
    @iso_db.schema.load_tables
    @iso_db.schema.tables.size.should == 2


    ct.columns['two_letter'].should be_primary_key
    ct.columns['two_letter'].declared_data_type.should == "TEXT"
    ct.columns['name'].should_not be_nullable
    ct.columns['name'].should be_not_null_constraint
    ct.columns['name'].should_not be_has_default_value
    ct.columns['id'].should_not be_auto_increment
  end

  it "loads the indexes" do
    c = @iso_db.schema.tables['country']
    c.indexes.size.should == 2
    c.indexes['country_name'].columns.size.should == 1
    c.indexes['country_name'].should_not be_unique
    c.indexes['country_name'].sequence_number.should == 0
    c.indexes['country_name'].columns.first.should == @iso_db.schema.tables['country'].columns['name']
    c.indexes['sqlite_autoindex_country_1'].should be_unique

    subc = @iso_db.schema.tables['subcountry']
    subc.indexes.size.should == 3
    subc.indexes['subcountry_country'].columns.first.should == @iso_db.schema.tables['subcountry'].columns['country']
  end
end
