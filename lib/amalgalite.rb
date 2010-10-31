#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

# check if sqlite3 has already been required.  Amalgalite conflicts with system
# level sqlite3 libraries.
unless $LOADED_FEATURES.grep( /sqlite3/ ).empty? then
  raise LoadError, "amalgalite conflicts with sqlite3-ruby, please choose one or the other."
end

module Amalgalite
  # 
  # Base class of all errors in Amalgalite
  #
  class Error < ::StandardError; end
end

# use a version subdirectory for extensions, initially to support windows, but
# why make a special case, it doesn't hurt anyone to have an extra subdir
# someplace 
require "amalgalite/#{RUBY_VERSION.sub(/\.\d$/,'')}/amalgalite3"

require 'amalgalite/aggregate'
require 'amalgalite/blob'
require 'amalgalite/boolean'
require 'amalgalite/busy_timeout'
require 'amalgalite/column'
require 'amalgalite/database'
require 'amalgalite/function'
require 'amalgalite/index'
require 'amalgalite/memory_database'
require 'amalgalite/paths'
require 'amalgalite/profile_tap'
require 'amalgalite/progress_handler'
require 'amalgalite/schema'
require 'amalgalite/sqlite3'
require 'amalgalite/statement'
require 'amalgalite/table'
require 'amalgalite/taps'
require 'amalgalite/trace_tap'
require 'amalgalite/type_map'
require 'amalgalite/version'
require 'amalgalite/view'
