#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  # 
  # Base class of all errors in Amalgalite
  #
  class Error < ::StandardError; end
end
%w[ blob 
    boolean 
    column 
    database 
    index 
    paths 
    profile_tap 
    schema 
    sqlite3 
    statement 
    table 
    taps
    trace_tap 
    type_map 
    version 
    view].each do |lib|
  require "amalgalite/#{lib}"
end
