require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite'
require 'amalgalite/trace_tap'
require 'amalgalite/profile_tap'
require 'amalgalite/taps/console'
require 'stringio'

describe Amalgalite::TraceTap do
  it "wraps up an object and delegates the 'trace' method to a method on that object" do
    s = StringIO.new
    tt = ::Amalgalite::TraceTap.new( s, 'puts' )
    tt.trace('test trace')
    s.string.should == "test trace\n"
  end
  
  it "raises an error if an the wrapped object does not respond to the indicated method"  do
    lambda{ ::Amalgalite::TraceTap.new( Object.new ) }.should raise_error( Amalgalite::Error )
  end
end

describe Amalgalite::ProfileTap do
  it "raises an error if an the wrapped object does not respond to the indicated method"  do
    lambda{ ::Amalgalite::ProfileTap.new( Object.new ) }.should raise_error( Amalgalite::Error )
  end
end

describe Amalgalite::Taps::StringIO do
  it "dumps profile information" do
    s = ::Amalgalite::Taps::StringIO.new
    s.profile( 'test', 42 )
    s.dump_profile
    s.string.should == "42 : test\ntest[test] => sum: 42, sumsq: 1764, n: 1, mean: 42.000000, stddev: 0.000000, min: 42, max: 42\n"
  end

  it "has a stdout tap" do
    s = ::Amalgalite::Taps::Stdout.new
  end
  
  it "has a stderr tap" do
    s = ::Amalgalite::Taps::Stderr.new
  end
end

describe Amalgalite::ProfileSampler do
  it "aggregates samples" do
    s = Amalgalite::ProfileSampler.new( 'test1' )
    s.sample( 42 )
    s.sample( 84 )
    s.sample( 21 )
    h = s.to_h
    h['min'].should == 21
    h['max'].should == 84
    h['mean'].should == 49
    h['n'].should == 3
  end
end
