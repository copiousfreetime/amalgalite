#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

#-------------------------------------------------------------------------------
# make sure our project's top level directory and the lib directory are added to
# the ruby search path.
#-------------------------------------------------------------------------------
$: << File.expand_path(File.join(File.dirname(__FILE__),"lib"))
$: << File.expand_path(File.dirname(__FILE__))


#-------------------------------------------------------------------------------
# load the global project configuration and add in the top level clean and
# clobber tasks so that other tasks can utilize those constants if necessary
# This loads up the defaults for the whole project configuration
#-------------------------------------------------------------------------------
require 'rubygems'
begin
  require 'tasks/config.rb'
  require 'rake/clean'
rescue LoadError
  abort "You probably want to run 'gem install configuration' then 'rake install_dependencies'"
end

desc "Install development dependencies"
task :install_dependencies => :clean do
  gv = [
    %w[ arrayfields     4.7.4 ],
    %w[ fastercsv       1.5.4 ],
    %w[ rspec           2.4.0 ],
    %w[ zip             2.0.2 ],
    %w[ rake-compiler   0.7.5 ],
    %w[ rcov            0.9.9 ] ]
  gv.each do |name, version|
   puts "Installing #{name}-#{version}"
   sh "gem install #{name} --version #{version} --no-rdoc --no-ri"
  end
end


#-------------------------------------------------------------------------------
# Main configuration for the project, these overwrite the items that are in
# tasks/config.rb
#-------------------------------------------------------------------------------
require 'amalgalite/paths'
require 'amalgalite/version'
Configuration.for("project") {
  name      "amalgalite"
  version   Amalgalite::VERSION
  author    "Jeremy Hinegardner"
  email     "jeremy@hinegardner.org"
  homepage  "http://copiousfreetime.rubyforge.org/amalgalite/"
}

#-------------------------------------------------------------------------------
# load up all the project tasks and setup the default task to be the
# test:default task.
#-------------------------------------------------------------------------------
if Rake.application.top_level_tasks.first !="install_dependencies" then
  Configuration.for("packaging").files.tasks.each do |tasklib|
    import tasklib
  end
  task :default => 'test:default'
end

#-------------------------------------------------------------------------------
# Finalize the loading of all pending imports and update the top level clobber
# task to depend on all possible sub-level tasks that have a name like
# ':clobber'  in other namespaces.  This allows us to say:
#
#   rake clobber
#
# and it will get everything.
#-------------------------------------------------------------------------------
begin
  Rake.application.load_imports
rescue LoadError
  abort "run 'rake install_dependencies'"
end

Rake.application.tasks.each do |t| 
  if t.name =~ /:clobber/ then
    task :clobber => [t.name] 
  end 
  if t.name =~ /:clean/ then
    task :clean => [t.name]
  end
end

