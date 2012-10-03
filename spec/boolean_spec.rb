require 'spec_helper'

require 'amalgalite'
require 'amalgalite/boolean'

describe Amalgalite::Boolean do
  %w[ True Y Yes T 1 ].each do |v|
    it "converts #{v} to true" do
      Amalgalite::Boolean.to_bool(v).should == true
    end
  end

  %w[ False F f No n 0 ].each do |v|
    it "converts #{v} to false " do
      Amalgalite::Boolean.to_bool(v).should == false
    end
  end

  %w[ other things nil ].each do |v|
    it "converts #{v} to nil" do
      Amalgalite::Boolean.to_bool(v).should == nil
    end
  end
end
