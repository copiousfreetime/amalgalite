require 'spec_helper'

require 'date'
require 'time'

describe "Integration specifications" do

  describe " - invalid queries" do
    it "raises error with an invalid syntax" do
      lambda{ @iso_db.prepare "SELECT from country" }.should raise_error( ::Amalgalite::SQLite3::Error )
    end

    it "raises error with invalid table" do
      lambda{ @iso_db.prepare "SELECT * FROM foo" }.should raise_error( ::Amalgalite::SQLite3::Error )
    end
    
    it "raises error with invalid column" do
      lambda{ @iso_db.prepare "SELECT foo FROM country" }.should raise_error( ::Amalgalite::SQLite3::Error )
    end
  end

  describe " - default types conversion" do

    { 
      "datetime"  => { :value => DateTime.now, :klass => DateTime }, 
      "timestamp" => { :value => Time.now, :klass => Time   } ,
      "date"      => { :value => Date.today, :klass => Date },
      "integer"   => { :value => 42, :klass => Integer },
      "double"    => { :value => 3.14, :klass => Float },
      "varchar"   => { :value => "foobarbaz", :klass => String },
      "boolean"   => { :value => true, :klass => TrueClass },
      "varchar(2)"=> { :value => nil, :klass => NilClass }
    }.each_pair do |sql_type, ruby_info|
      it "converts a ruby obj (#{ruby_info[:value].to_s}) of #{ruby_info[:klass]} to an SQL type of #{sql_type} and back again " do
        db = Amalgalite::Database.new( SpecInfo.test_db )
        db.execute "CREATE TABLE t( c #{sql_type} )"
        db.execute "insert into t (c) values ( ? )", ruby_info[:value]
        rows = db.execute "select * from t"
        rows.first['c'].should be_kind_of(ruby_info[:klass])

        if [ DateTime, Time ].include?( ruby_info[:klass] ) then
          rows.first['c'].strftime("%Y-%m-%d %H:%M:%S").should eql(ruby_info[:value].strftime("%Y-%m-%d %H:%M:%S"))
        else
          rows.first['c'].should eql(ruby_info[:value])
        end
        db.close
      end
    end
  end

  describe " - storage type conversion" do
    { 
      "datetime"  => { :value => DateTime.now, :result => DateTime.now.strftime("%Y-%m-%dT%H:%M:%S%Z") } ,
      "timestamp" => { :value => Time.now,     :result => Time.now.to_s },
      "date"      => { :value => Date.today,   :result => Date.today.to_s },
      "integer"   => { :value => 42,           :result => 42   } ,
      "double"    => { :value => 3.14,         :result => 3.14 }  ,
      "varchar"   => { :value => "foobarbaz",  :result => "foobarbaz" },
      "boolean"   => { :value => true,         :result => "true" },
      "varchar(2)"=> { :value => nil,          :result => nil }
    }.each_pair do |sql_type, ruby_info|
      it "converts a ruby obj (#{ruby_info[:value].to_s}) of class #{ruby_info[:value].class.name} to an SQL type of #{sql_type} and back to a storage type" do
        db = Amalgalite::Database.new( SpecInfo.test_db )
        db.type_map = Amalgalite::TypeMaps::StorageMap.new
        db.execute "CREATE TABLE t( c #{sql_type} )"
        db.execute "insert into t (c) values ( ? )", ruby_info[:value]
        rows = db.execute "select * from t"
        rows.first['c'].should eql(ruby_info[:result])
        db.close
      end
    end
  end

  describe " - text type conversion" do
    { 
      "datetime"  => { :value => DateTime.now, :result => DateTime.now.strftime("%Y-%m-%dT%H:%M:%S%Z") } ,
      "timestamp" => { :value => Time.now,     :result => Time.now.to_s },
      "date"      => { :value => Date.today,   :result => Date.today.to_s },
      "integer"   => { :value => 42,           :result => "42"   } ,
      "double"    => { :value => 3.14,         :result => "3.14" }  ,
      "varchar"   => { :value => "foobarbaz",  :result => "foobarbaz" },
      "boolean"   => { :value => true,         :result => "true" },
      "varchar(2)"=> { :value => nil,          :result => "" }
    }.each_pair do |sql_type, ruby_info|
      it "converts a ruby obj (#{ruby_info[:value].to_s}) of class #{ruby_info[:value].class.name} to an SQL type of #{sql_type} and back to text" do
        db = Amalgalite::Database.new( SpecInfo.test_db )
        db.type_map = Amalgalite::TypeMaps::TextMap.new
        db.execute "CREATE TABLE t( c #{sql_type} )"
        db.execute "insert into t (c) values ( ? )", ruby_info[:value]
        rows = db.execute "select * from t"
        rows.first['c'].should eql(ruby_info[:result])
        db.close
      end
    end
  end
end

