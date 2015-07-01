require 'mkmf'
require 'rbconfig'

# used by the ext:build_win-1.x.x tasks, really no one else but jeremy should be
# using this hack
$ruby = ARGV.shift if ARGV[0]

# make available table and column meta data api
$CFLAGS += " -DSQLITE_ENABLE_COLUMN_METADATA=1"  
$CFLAGS += " -DSQLITE_ENABLE_DBSTAT_VTAB=1"
$CFLAGS += " -DSQLITE_ENABLE_RTREE=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS3=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS4=1"
$CFLAGS += " -DSQLITE_ENABLE_STAT4=1"

# we compile sqlite the same way that the installation of ruby is compiled.
if RbConfig::MAKEFILE_CONFIG['configure_args'].include?( "--enable-pthread" ) then
  $CFLAGS += " -DSQLITE_THREADSAFE=1"
else
  $CFLAGS += " -DSQLITE_THREADSAFE=0"
end

# remove the -g flags  if it exists
%w[ -ggdb\\d* -g\\d* ].each do |debug|
  $CFLAGS = $CFLAGS.gsub(/#{debug}/,'')
  RbConfig::MAKEFILE_CONFIG['debugflags'] = RbConfig::MAKEFILE_CONFIG['debugflags'].gsub(/#{debug}/,'')   if RbConfig::MAKEFILE_CONFIG['debugflags']
end

%w[ shorten-64-to-32 write-strings ].each do |warning|
  $CFLAGS = $CFLAGS.gsub(/-W#{warning}/,'')
  RbConfig::MAKEFILE_CONFIG['warnflags'] = RbConfig::MAKEFILE_CONFIG['warnflags'].gsub(/-W#{warning}/,'') if RbConfig::MAKEFILE_CONFIG['warnflags'] 
end



subdir = RUBY_VERSION.sub(/\.\d$/,'')
create_makefile("amalgalite/#{subdir}/amalgalite")
