require File.expand_path( File.join( File.dirname( __FILE__ ), "spec_helper.rb" ) )
require 'amalgalite/type_maps/storage_map'

describe Amalgalite::TypeMaps::StorageMap do
  before(:each) do
    @map = Amalgalite::TypeMaps::StorageMap.new
  end

  describe "#bind_type_of" do

    it "Float is bound to DataType::FLOAT" do
      @map.bind_type_of( 3.14 ).should == ::Amalgalite::SQLite3::Constants::DataType::FLOAT
    end

    it "Fixnum is bound to DataType::INTGER" do
      @map.bind_type_of( 42 ).should == ::Amalgalite::SQLite3::Constants::DataType::INTEGER
    end

    it "nil is bound to DataType::NULL" do
      @map.bind_type_of( nil ).should == ::Amalgalite::SQLite3::Constants::DataType::NULL
    end

    it "::Amalgalite::Blob is bound to DataType::BLOB" do
      @map.bind_type_of( ::Amalgalite::Blob.new( :string => "testing mapping", :column => true )  ).should == ::Amalgalite::SQLite3::Constants::DataType::BLOB
    end

    it "everything else is bound to DataType::TEXT" do
      @map.bind_type_of( "everything else" ).should == ::Amalgalite::SQLite3::Constants::DataType::TEXT
    end

  end

  describe "#result_value_of" do
    it "returns the original object for everything passed in" do
      @map.result_value_of( "doesn't matter", 42 ).should == 42
    end
  end
end
