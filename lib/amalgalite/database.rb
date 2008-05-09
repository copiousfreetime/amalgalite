#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
require 'amalgalite/statement'

module Amalgalite
  class Database

    class InvalidModeError < ::Amalgalite::Error; end
    ##
    # Create a new Amalgalite database
    #
    # :call-seq:
    #   Amalgalite::Database.new( filename, "r", opts = {}) -> Database
    #
    # The first parameter is the filename of the sqlite database.  
    # The second parameter is the standard file modes of how to open a file.
    #
    # The modes are:
    #   * r  - Read-only
    #   * r+ - Read/write, an error is thrown if the database does not already
    #          exist.
    #   * w+ - Read/write, create a new database if it doesn't exist
    #          This is the default as this is how most databases will want
    #          to be utilized.
    #
    # opts is a hash of available options for the database:
    #
    #   :utf16 : option to set the database to a utf16 encoding if creating 
    #            a database. By default, databases are created with an 
    #            encoding of utf8.  Setting this to true and opening an already
    #            existing database has no effect.
    #
    #
    include Amalgalite::SQLite3::Constants
    VALID_MODES = {
      "r"  => Open::READONLY,
      "r+" => Open::READWRITE,
      "w+" => Open::READWRITE | Open::CREATE,
    }

    attr_reader :api

    ##
    # Create a new database 
    #
    def initialize( filename, mode = "w+", opts = {})
      unless VALID_MODES.keys.include?( mode ) 
        raise InvalidModeError, "#{mode} is invalid, must be one of #{VALID_MODES.keys.join(', ')}" 
      end

      if not File.exist?( filename ) and opts[:utf16] then
        @api = Amalgalite::SQLite3::Database.open16( filename )
      else
        @api = Amalgalite::SQLite3::Database.open( filename, VALID_MODES[mode] )
      end
    end

    ##
    # Is the database utf16 or not?  A database is utf16 if the encoding is not
    # UTF-8.  Database can only be UTF-8 or UTF-16, and the default is UTF-8
    #
    def utf16?
      unless @utf16.nil?
        @utf16 = (encoding != "UTF-8") 
      end
      return @utf16
    end

    ## 
    # return the encoding of the database
    #
    def encoding
      unless @encoding
        @encoding = "UTF-8"
        #@encoding = db.pragma( "encoding" )
      end
      return @encoding
    end

    ##
    # Prepare a statement for execution
    #
    def prepare( sql )
      return Amalgalite::Statement.new( self, sql )
    end

  end
end

