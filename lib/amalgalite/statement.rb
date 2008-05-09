#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
module Amalgalite
  class Statement

    attr_reader :db
    attr_reader :sql
    attr_reader :api

    def initialize( db, sql )
      @db = db
      @sql = sql
     
      prepare_method =  @db.utf16? ? :prepare16 : :prepare
      @api = @db.api.send( prepare_method, sql )
    end
  end
end

 
