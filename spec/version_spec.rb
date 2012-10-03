require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
require 'amalgalite/version'

describe "Amalgalite::VERSION" do
  it "should have a version string" do
    Amalgalite::VERSION.should =~ /\d+\.\d+\.\d+/
  end
end
