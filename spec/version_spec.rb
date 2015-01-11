require 'spec_helper'
require 'amalgalite/version'

describe "Amalgalite::VERSION" do
  it "should have a version string" do
    expect(Amalgalite::VERSION).to match( /\d+\.\d+\.\d+/ )
  end
end
