# To be used if the gem has extensions.
# If this task set is inclueded then you will need to also have
#
#   spec.add_development_dependency( 'rake-compiler', '~> 0.8.1' )
#
# in your top level rakefile
begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new( This.name ) do |ext|
    ext.ext_dir   = File.join( 'ext', This.name, "c" )
    ext.lib_dir   = File.join( 'lib', This.name )
    ext.gem_spec  = This.ruby_gemspec

    ext.cross_compile  = true  # enable cross compilation (requires cross compile toolchain)
    ext.cross_platform = %w[
      x86-mingw32
      x64-mingw-ucrt
      x64-mingw32
    ]
  end

  task :test_requirements => :compile
rescue LoadError
  This.task_warning( 'extension' )
end

CLOBBER << "lib/**/*.{jar,so,bundle}"
CLOBBER << "lib/#{This.name}/{1,2,3}.*/"
