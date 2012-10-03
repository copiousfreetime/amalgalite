require 'spec_helper'

require 'amalgalite/packer'

describe "Amalgalite::Packer" do
  before( :each ) do
    @table = Amalgalite::Requires::Bootstrap::DEFAULT_BOOTSTRAP_TABLE
    @packer = Amalgalite::Packer.new( :table_name => @table )
  end

  after( :each ) do 
    FileUtils.rm_f Amalgalite::Requires::Bootstrap::DEFAULT_DB
  end

  it "does not load the amalgalite/requires file" do
    $LOADED_FEATURES.should_not be_include("amalgalite/requires")
  end

  it "packs amalgalite into a bootstrap database" do
    @packer.pack( Amalgalite::Packer.amalgalite_require_order )
    db = Amalgalite::Database.new( @packer.dbfile )
    db.schema.tables[ @table ].should_not be_nil
    count = db.execute("SELECT count(1) FROM #{@table}").first
    count.first.should eql(Amalgalite::Packer.amalgalite_require_order.size)
  end

  it "recreates the table if :drop_table option is given " do
    @packer.pack( Amalgalite::Packer.amalgalite_require_order )
    db = Amalgalite::Database.new( @packer.dbfile )
    db.schema.tables[ @table ].should_not be_nil
    count = db.execute("SELECT count(1) FROM #{@table}").first
    count.first.should eql(Amalgalite::Packer.amalgalite_require_order.size)

    np = Amalgalite::Packer.new( :drop_table => true, :table_name => @table  )
    np.options[ :drop_table ].should eql(true)
    np.check_db( db )
    count = db.execute("SELECT count(1) FROM #{@table}").first
    count.first.should eql(0)

  end

  it "compresses the content if told too" do 
    @packer.options[ :compressed ] = true
    @packer.pack( Amalgalite::Packer.amalgalite_require_order )
    db = Amalgalite::Database.new( @packer.dbfile )
    orig = IO.read( File.join( File.dirname( __FILE__ ), "..", "lib", "amalgalite.rb" ) )
    zipped = db.execute("SELECT contents FROM #{@table} WHERE filename = 'amalgalite'")
    expanded = Amalgalite::Packer.gunzip( zipped.first['contents'].to_s )
    expanded.should eql(orig)
  end

  it "has all the lib files in the amalgalite gem" do
    ro = Amalgalite::Packer.amalgalite_require_order
    glist = IO.readlines("Manifest.txt").select { |l| l.index("lib/amalgalite") == 0 }
    glist.map! { |l| l.strip.sub("lib/","") }
    (glist - ro).each do |l|
      l.should_not =~ /amalgalite/
    end
  end
end
