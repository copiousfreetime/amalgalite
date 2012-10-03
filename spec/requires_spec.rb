require 'spec_helper'
require 'amalgalite/requires'

#describe Amalgalite::Requires do
#  it "#require_order has all files in 'lib' and no more" do
#    dir_files = Dir.glob( File.join( Amalgalite::Paths.lib_path , "**", "*.rb" ) )
#    require_files = Amalgalite::Requires.require_order.collect { |r| Amalgalite::Paths.lib_path r }
#    dir_files.size.should == require_files.size
#    (dir_files - require_files).size.should == 0
#    (require_files - dir_files).size.should == 0
#  end
#
#  it "can compress and uncompress data" do
#    s = IO.read( __FILE__ )
#    s_gz = Amalgalite::Requires.gzip( s )
#    s.should == Amalgalite::Requires.gunzip( s_gz )
#  end
#end


describe Amalgalite::Requires do
  it "can import to an in-memory database" do
    sql = <<-SQL
CREATE TABLE rubylibs (
      id                   INTEGER PRIMARY KEY AUTOINCREMENT,
      filename   TEXT UNIQUE,
      compressed BOOLEAN,
      contents   BLOB
      );
INSERT INTO "rubylibs" VALUES(1, "application", "false", 'A=1');
SQL
    r = Amalgalite::Requires.new(:dbfile_name => ":memory:")
    r.import(sql)
    r.file_contents( "application" ).should == "A=1"
  end


  it "gives equal instances for file databases" do
    a = Amalgalite::Requires.new( :dbfile_name => SpecInfo.test_db )
    b = Amalgalite::Requires.new( :dbfile_name => SpecInfo.test_db )    

    a.db_connection.should equal( b.db_connection )
  end


  it "gives separate instances for in-memory databases" do
    a = Amalgalite::Requires.new( :dbfile_name => ":memory:" )
    b = Amalgalite::Requires.new( :dbfile_name => ":memory:" )

    a.db_connection.should_not equal(b.db_connection)
  end

  
end
