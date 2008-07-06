require 'rubygems'
require 'mkrf'
require 'rbconfig'
Mkrf::Generator.new('amalgalite3') do |g|
  # turn on some compilation options
  g.cflags << " -DSQLITE_ENABLE_COLUMN_METADATA=1"  # make available table and column meta data api

  # we compile sqlite the same way that the installation of ruby is compiled.
  if Config::CONFIG['configure_args'].include?( "--enable-pthread" ) then
    g.cflags << " -DSQLITE_THREADSAFE=1"
  else
    g.cflags << " -DSQLITE_THREADSAFE=0"
  end
end
