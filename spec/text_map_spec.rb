require File.expand_path( File.join( File.dirname( __FILE__ ), "spec_helper.rb" ) )
require 'amalgalite/type_maps/text_map'

describe Amalgalite::TypeMaps::TextMap do
  before(:each) do
    @map = Amalgalite::TypeMaps::TextMap.new
  end

  describe "#bind_type_of" do
    it "returnes text for everything" do
      @map.bind_type_of( 3.14 ).should == ::Amalgalite::SQLite3::Constants::DataType::TEXT
    end
  end

  describe "#result_value_of" do
    it "returns the string value of the object for everything passed in" do
      @map.result_value_of( "doesn't matter", 42 ).should == "42"
    end
  end
end
