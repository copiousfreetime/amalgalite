#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
module Amalgalite
  class Statement

    attr_reader :db
    attr_reader :sql
    attr_reader :stmt

    def initialize( db, sql )
      @db = db
      @sql = sql
      
      if @db.utf16? then
        @stmt = @db.db.prepare16( sql )
      else
        @stmt = @db.db.prepare( sql )
      end
    end
  end
end

 
