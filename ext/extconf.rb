require 'mkmf'
require 'rbconfig'

# make available table and column meta data api
$CFLAGS += " -DSQLITE_ENABLE_COLUMN_METADATA=1"  
if enable_config( 'requires-bootstrap', false)  then
  $CFLAGS += " -DAMALGALITE_ENABLE_REQUIRES_BOOTSTRAP=1"
end

# we compile sqlite the same way that the installation of ruby is compiled.
if Config::CONFIG['configure_args'].include?( "--enable-pthread" ) then
  $CFLAGS += " -DSQLITE_THREADSAFE=1"
else
  $CFLAGS += " -DSQLITE_THREADSAFE=0"
end
create_makefile('amalgalite3')
