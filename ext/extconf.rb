require 'mkmf'
require 'rbconfig'

# make available table and column meta data api
$CFLAGS += " -DSQLITE_ENABLE_COLUMN_METADATA=1"  
$CFLAGS += " -DSQLITE_ENABLE_RTREE=1"
$CFLAGS += " -DSQLITE_OMIT_BUILTIN_TEST=1"

# we compile sqlite the same way that the installation of ruby is compiled.
if Config::CONFIG['configure_args'].include?( "--enable-pthread" ) then
  $CFLAGS += " -DSQLITE_THREADSAFE=1"
else
  $CFLAGS += " -DSQLITE_THREADSAFE=0"
end

# remove the -g if it exists
$CFLAGS = $CFLAGS.gsub(/-g/,'')

create_makefile('amalgalite3')
