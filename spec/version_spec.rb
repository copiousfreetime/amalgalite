require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))
require 'amalgalite/version'

describe "Amalgalite::Version" do
  it "should have a version string" do
    Amalgalite::Version.to_s.should =~ /\d+\.\d+\.\d+/
    Amalgalite::VERSION.should =~ /\d+\.\d+\.\d+/
  end
end
