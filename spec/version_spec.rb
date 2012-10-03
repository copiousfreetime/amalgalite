require 'spec_helper'
require 'amalgalite/version'

describe "Amalgalite::VERSION" do
  it "should have a version string" do
    Amalgalite::VERSION.should =~ /\d+\.\d+\.\d+/
  end
end
