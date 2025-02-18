# frozen_string_literal: true

# To be used if the gem has extensions.
# If this task set is inclueded then you will need to also have
#
# gem "rake-compiler", "~> 1.0" in your Gemfile
#
# in your top level rakefile
begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new( This.name ) do |ext|
    ext.ext_dir   = File.join( 'ext', This.name, "c" )
    ext.lib_dir   = File.join( 'lib', This.name )
    ext.gem_spec  = This.ruby_gemspec

    ext.cross_compile  = true  # enable cross compilation (requires cross compile toolchain)
    ext.cross_platform = This.cross_platforms
  end

  desc "compile before testing"
  task test_requirements: :compile
rescue LoadError
  This.task_warning("extension")
end

CLOBBER << "lib/**/*.{jar,so,bundle}"
CLOBBER << "lib/#{This.name}/{1,2,3}.*/"
