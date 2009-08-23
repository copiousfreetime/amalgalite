require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite/type_maps/default_map'

describe Amalgalite::TypeMaps::DefaultMap do
  before(:each) do
    @map = Amalgalite::TypeMaps::DefaultMap.new
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
      @map.bind_type_of( ::Amalgalite::Blob.new( :column => true, :string => "just a test" ) ).should == ::Amalgalite::SQLite3::Constants::DataType::BLOB
    end

    it "everything else is bound to DataType::TEXT" do
      @map.bind_type_of( "everything else" ).should == ::Amalgalite::SQLite3::Constants::DataType::TEXT
    end

  end


  describe "#result_value_of" do

    it "Numeric's are returned" do
      y = 42
      x = @map.result_value_of( "INT", 42 )
      x.object_id.should == y.object_id
    end

    it "Nil is returned" do
      @map.result_value_of( "NULL", nil ).should == nil
    end

    it "DateTime is returned for delcared types of 'datetime'" do
      @map.result_value_of( "DaTeTiME", "2008-04-01 23:23:23" ).should be_kind_of(DateTime)
    end

    it "Date is returned for declared types of 'date'" do
      @map.result_value_of( "date", "2008-04-01 23:42:42" ).should be_kind_of(Date)
    end

    it "Time is returned for declared types of 'time'" do
      @map.result_value_of( "timestamp", "2008-04-01T23:42:42" ).should be_kind_of(Time)
    end

    it "Float is returned for declared types of 'double'" do
      @map.result_value_of( "double", "3.14" ).should be_kind_of(Float)
    end
    
    it "Float is returned for declared types of 'float'" do
      @map.result_value_of( "float", "3.14" ).should be_kind_of(Float)
    end

    it "Integer is returned for declared types of 'int'" do
      @map.result_value_of( "int", "42" ).should be_kind_of(Integer)
    end

    it "boolean is returned for declared types of 'bool'" do
      @map.result_value_of( "bool", "True" ).should == true
    end

    it "Blob is returned for declared types of 'blob'" do
      blob = @map.result_value_of( "blob", "stuff")
      blob.to_s.should == "stuff"
    end

    it "String is returned for delcared types of 'string'" do
      @map.result_value_of( "string", "stuff").should == "stuff"
    end

    it "raises and error if an unknown sql type is returned" do
      x = nil
      lambda{ x = @map.result_value_of( "footype", "foo" ) }.should raise_error( ::Amalgalite::Error )
    end
    
    it "raises and error if an ruby class is attempted to be mapped" do
      lambda{ @map.result_value_of( "footype", 1..3 ) }.should raise_error( ::Amalgalite::Error )
    end
  end
end
