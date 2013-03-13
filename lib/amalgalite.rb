#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

# check if sqlite3 has already been required.  Amalgalite conflicts with system
# level sqlite3 libraries.
unless $LOADED_FEATURES.grep( /\Asqlite3/ ).empty? then
  raise LoadError, "amalgalite conflicts with sqlite3, please choose one or the other."
end

module Amalgalite
  # 
  # Base class of all errors in Amalgalite
  #
  class Error < ::StandardError; end
end

# Load the binary extension, try loading one for the specific version of ruby
# and if that fails, then fall back to one in the top of the library.
# this is the method recommended by rake-compiler
begin
  # this will be for windows
  require "amalgalite/#{RUBY_VERSION.sub(/\.\d$/,'')}/amalgalite"
rescue LoadError
  # everyone else.
  require 'amalgalite/amalgalite'
end


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
