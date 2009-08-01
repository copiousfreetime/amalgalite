require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))

require 'amalgalite'

class SpecInfo
  class << self
    def test_db
      @test_db ||=  File.expand_path(File.join(File.dirname(__FILE__), "test.db"))
    end

    def test_schema_file
      @test_schema_file ||= File.expand_path(File.join(File.dirname(__FILE__),"iso-3166-schema.sql"))
    end

    def make_iso_db
      @iso_db ||= File.expand_path(File.join(File.dirname(__FILE__), "iso-3166.db"))
      @new_is_db =  File.expand_path(File.join(File.dirname(__FILE__), "iso-3166-testing.db"))
      FileUtils.cp @iso_db, @new_is_db
      return @new_is_db
    end

  end
end

