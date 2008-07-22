#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  #
  # a class representing the meta information about an SQLite index
  #
  class Index
    # the name of the index
    attr_reader   :name

    # the sql statement that created the index
    attr_reader   :sql

    # the table the index is for
    attr_accessor :table

    # the columns that make up this index, in index order
    attr_accessor :columns

    # sqlite sequence number of the index
    attr_accessor :sequence_number

    # is the index unique
    attr_writer   :unique

    def initialize( name, sql, table ) 
      @name             = name
      @sql              = sql
      @table            = table
      @columns          = []
      @sequence_number  = nil
      @unique           = nil
    end

    def unique?
      return @unique
    end
  end
end

