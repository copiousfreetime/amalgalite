require 'rubygems'
require 'mkrf'
Mkrf::Generator.new('amalgalite3') do |g|
  # turn on some compilation options
  g.cflags << " -DSQLITE_ENABLE_COLUMN_METADATA=1"  # make available table and column meta data api
end
