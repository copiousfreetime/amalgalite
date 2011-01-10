require File.expand_path(File.join(File.dirname(__FILE__),%w[ .. spec_helper.rb ]))

require 'amalgalite/sqlite3/constants'

describe Amalgalite::SQLite3::Constants do

  it "has Open constants" do
    Amalgalite::SQLite3::Constants::Open::READONLY.should > 0
  end

  describe 'ResultCode' do 
    it "has constants" do
      Amalgalite::SQLite3::Constants::ResultCode::OK.should == 0
    end

    it "can return the constant from a number" do
      c = Amalgalite::SQLite3::Constants::ResultCode.name_from_value( 21 )
      c.should == "MISUSE"
    end

    it "can return the number from a name" do
      v = Amalgalite::SQLite3::Constants::ResultCode.value_from_name( "MISUSE" )
      v.should == 21
    end
  end

  describe "DataType" do
    it "has constants" do
      Amalgalite::SQLite3::Constants::DataType::NULL.should == 5
    end

    it "can return the constant from a number" do
      c = Amalgalite::SQLite3::Constants::DataType.name_from_value( 5 )
      c.should == "NULL"
    end

    it "can return the number from a name" do
      v = Amalgalite::SQLite3::Constants::DataType.value_from_name( "Null" )
      v.should == 5
    end

  end

  describe "Config" do
    it "has constants" do
      Amalgalite::SQLite3::Constants::Config::HEAP.should == 8
    end

    it "can return the constant from a number" do
      c = Amalgalite::SQLite3::Constants::Config.name_from_value( 8 )
      c.should == "HEAP"
    end

    it "can return the number from a name" do
      v = Amalgalite::SQLite3::Constants::Config.value_from_name( "heap" )
      v.should == 8
    end

  end

  describe 'Status' do
    it "has constants" do
      Amalgalite::SQLite3::Constants::Status::MEMORY_USED.should == 0
    end

    it "can return the constant from a number" do
      c = Amalgalite::SQLite3::Constants::Status.name_from_value( 3 )
      c.should == "SCRATCH_USED"
    end

    it "can return the number from a name" do
      v = Amalgalite::SQLite3::Constants::Status.value_from_name( "memory_used" )
      v.should == 0
    end
  end

  describe 'DBStatus' do
    it "has constants" do
      Amalgalite::SQLite3::Constants::DBStatus::LOOKASIDE_USED.should == 0
    end

    it "can return the constant from a number" do
      c = Amalgalite::SQLite3::Constants::DBStatus.name_from_value( 0 )
      c.should == "LOOKASIDE_USED"
    end

    it "can return the number from a name" do
      v = Amalgalite::SQLite3::Constants::DBStatus.value_from_name( "lookaside_used" )
      v.should == 0
    end
  end

  describe "StatementStatus" do
    it "has constants" do
      Amalgalite::SQLite3::Constants::StatementStatus::AUTOINDEX.should == 3
    end

    it "can return the constant from a number" do
      c = Amalgalite::SQLite3::Constants::StatementStatus.name_from_value( 3 )
      c.should == "AUTOINDEX"
    end

    it "can return the number from a name" do
      v = Amalgalite::SQLite3::Constants::StatementStatus.value_from_name( "autoindex" )
      v.should == 3
    end
  end
end
