#!/usr/bin/env ruby

$: << "../ext"
require 'amalgalite3'

puts "Before $\" : #{$".inspect}"
Amalgalite::Requires::Bootstrap.lift( "filestore.db", "files", "id", "path", "data" )

puts "After $\" : #{$".inspect}"
a = A.new
a.a

