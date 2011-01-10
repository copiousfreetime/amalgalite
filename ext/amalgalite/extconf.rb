require 'mkmf'
require 'rbconfig'

# make available table and column meta data api
$CFLAGS += " -DSQLITE_ENABLE_COLUMN_METADATA=1"  
$CFLAGS += " -DSQLITE_ENABLE_RTREE=1"

# we compile sqlite the same way that the installation of ruby is compiled.
if Config::CONFIG['configure_args'].include?( "--enable-pthread" ) then
  $CFLAGS += " -DSQLITE_THREADSAFE=1"
else
  $CFLAGS += " -DSQLITE_THREADSAFE=0"
end

# remove the -g if it exists
$CFLAGS = $CFLAGS.gsub(/-g/,'')

# remove -Wall if it exists
$CFLAGS = $CFLAGS.gsub(/-Wall/,'')
#$CFLAGS += " -Wall"

# there are issues with the mingw compiler and compiling sqlite with debugging
# on.  You will get lots of warnings of the sort 
#
#   Warning: .stabs: description field '16274' too big, try a different debug format
#
# it appears to be a known issue and has no affect on the normal usage of sqlite
#
# warnflags and debugflags appear to be 1.9 constructs
#
if Config::CONFIG['arch'] =~ /(mswin|mingw)/i then
  Config::CONFIG['debugflags'] = Config::CONFIG['debugflags'].gsub(/-g/,'')   if Config::CONFIG['debugflags']
  Config::CONFIG['warnflags']  = Config::CONFIG['warnflags'].gsub(/-Wall/,'') if Config::CONFIG['warnflags']
end
subdir = RUBY_VERSION.sub(/\.\d$/,'')
create_makefile("amalgalite/#{subdir}/amalgalite3")
