require 'amalgalite'

module Amalgalite
  class Iso3166Database < Database
    def self.country_data_file
      @country_data_file ||= File.expand_path( File.join( File.dirname(__FILE__), "data", "iso-3166-country.txt" ) )
    end

    def self.subcountry_data_file
      @subcountry_data_file ||= File.expand_path( File.join( File.dirname(__FILE__), "data", "iso-3166-subcountry.txt" ) )
    end

    def self.schema_file
      @schema_file ||= File.expand_path(File.join(File.dirname(__FILE__), "data", "iso-3166-schema.sql"))
    end

    def self.default_db_file
      @db_file ||= File.expand_path(File.join(File.dirname(__FILE__), "data", "iso-3166.db"))

    end

    def self.memory
      Iso3166Database.new( ":memory:" )
    end

    def initialize( path = Iso3166Database.default_db_file )
      @path = path 
      super( @path )
      install_schema( self )
      populate( self )
    end

    def duplicate( slug )
      dirname = File.dirname( @path )
      bname = File.basename( @path, ".db" )
      new_name = File.join( dirname, "#{bname}_#{slug}.db" )
      File.unlink( new_name ) if File.exist?( new_name )
      new_db = replicate_to( new_name )
      new_db.close
      return new_name
    end

    def install_schema( db )
      db.execute_batch( IO.read( Iso3166Database.schema_file ) );
    end

    def populate( db )
      db.import_csv_to_table( Iso3166Database.country_data_file, "country", :col_sep => "|" )
      db.import_csv_to_table( Iso3166Database.subcountry_data_file, "subcountry", :col_sep => "|" )
    end

    def remove
      File.unlink( @path ) if File.exist?( @path )
    end
  end
end


