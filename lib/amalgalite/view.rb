#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  #
  # a class representing the meta information about an SQLite view
  #
  class View

    # the table name
    attr_reader   :name

    # the original sql that was used to create this table
    attr_reader   :sql

    def initialize( name, sql ) 
      @name    = name
      @sql     = sql
    end
  end
end

