#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  class Error < ::StandardError; end
end
require 'amalgalite/version'
require 'amalgalite/sqlite3'
require 'amalgalite/paths'
require 'amalgalite/database'
