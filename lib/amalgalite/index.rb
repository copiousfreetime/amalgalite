#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  #
  # a class representing the meta information about an SQLite index
  #
  class Index
    attr_reader   :name
    attr_reader   :sql
    attr_accessor :table

    def initialize( name, sql, table ) 
      @name  = name
      @sql   = sql
      @table = table
    end
  end
end

