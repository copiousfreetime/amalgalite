require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe Amalgalite::Paths do
  before(:each) do
    @root_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    @root_dir += "/"
  end

  it "root dir should be correct" do
    Amalgalite::Paths.root_dir.should == @root_dir
  end

  it "config_path should be correct" do
    Amalgalite::Paths.config_path.should == File.join(@root_dir, "config/")
  end

  it "data path should be correct" do
    Amalgalite::Paths.data_path.should == File.join(@root_dir, "data/")
  end

  it "lib path should be correct" do
    Amalgalite::Paths.lib_path.should == File.join(@root_dir, "lib/")
  end

  it "ext path should be correct" do
    Amalgalite::Paths.ext_path.should == File.join(@root_dir, "ext/")
  end
end
