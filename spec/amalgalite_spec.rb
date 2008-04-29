require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe Amalgalite do
  before(:each) do
    @root_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    @root_dir += "/"
  end

  it "root dir should be correct" do
    Amalgalite.root_dir.should == @root_dir
  end

  it "config_path should be correct" do
    Amalgalite.config_path.should == File.join(@root_dir, "config/")
  end

  it "data path should be correct" do
    Amalgalite.data_path.should == File.join(@root_dir, "data/")
  end

  it "lib path should be correct" do
    Amalgalite.lib_path.should == File.join(@root_dir, "lib/")
  end

  it "ext path should be correct" do
    Amalgalite.ext_path.should == File.join(@root_dir, "ext/")
  end
end
