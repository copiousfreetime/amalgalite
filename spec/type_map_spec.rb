require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'amalgalite/type_map'

describe Amalgalite::TypeMap do
  it "#bind_type_of raises NotImplemented error" do
    tm = Amalgalite::TypeMap.new
    lambda { tm.bind_type_of( Object.new ) }.should raise_error( NotImplementedError )
  end

  it "#result_value_of raises NotImplemented error" do
    tm = Amalgalite::TypeMap.new
    lambda { tm.result_value_of( "foo", Object.new ) }.should raise_error( NotImplementedError )
  end
end
