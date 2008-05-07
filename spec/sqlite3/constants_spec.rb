require File.expand_path(File.join(File.dirname(__FILE__),%w[ .. spec_helper.rb ]))

describe Amalgalite::SQLite3::Constants do

  it "has Open constants" do
    Amalgalite::SQLite3::Constants::Open::READONLY.should > 0
  end
  
  it "has DataType constants" do
    Amalgalite::SQLite3::Constants::DataType::BLOB.should > 0
  end

  it "has ResultCode constants" do
    Amalgalite::SQLite3::Constants::ResultCode::OK.should == 0
  end

end
