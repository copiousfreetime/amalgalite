#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  #
  # abstrace of the meta informationa bout 1 table
  #
  class Table
    attr_reader   :name
    attr_reader   :sql
    attr_accessor :indexes

    def initialize( name, sql ) 
      @name    = name
      @sql     = sql
      @indexes = []
    end
  end
end

