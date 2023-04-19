require 'mkmf'
require 'rbconfig'

# used by the ext:build_win-1.x.x tasks, really no one else but jeremy should be
# using this hack
$ruby = ARGV.shift if ARGV[0]

# make available table and column meta data api
$CFLAGS += " -DSQLITE_ENABLE_BYTECODE_VTAB=1"
$CFLAGS += " -DSQLITE_ENABLE_COLUMN_METADATA=1"
$CFLAGS += " -DSQLITE_ENABLE_DBSTAT_VTAB=1"
$CFLAGS += " -DSQLITE_ENABLE_DBPAGE_VTAB=1"
$CFLAGS += " -DSQLITE_ENABLE_EXPLAIN_COMMENTS=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS3=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS4=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS5=1"
$CFLAGS += " -DSQLITE_ENABLE_GEOPOLY=1"
$CFLAGS += " -DSQLITE_ENABLE_MATH_FUNCTIONS=1"
$CFLAGS += " -DSQLITE_ENABLE_MEMORY_MANAGEMENT=1"
$CFLAGS += " -DSQLITE_ENABLE_NORMALIZE=1"
$CFLAGS += " -DSQLITE_ENABLE_NULL_TRIM=1"
$CFLAGS += " -DSQLITE_ENABLE_PREUPDATE_HOOK=1"
$CFLAGS ++ " -DSQLITE_EANBLE_QPSG=1"
$CFLAGS += " -DSQLITE_ENABLE_RBU=1"
$CFLAGS += " -DSQLITE_ENABLE_RTREE=1"
$CFLAGS += " -DSQLITE_ENABLE_SESSION=1"
$CFLAGS += " -DSQLITE_ENABLE_SNAPSHOT=1"
$CFLAGS += " -DSQLITE_ENABLE_STMTVTAB=1"
$CFLAGS += " -DSQLITE_ENABLE_STAT4=1"
$CFLAGS += " -DSQLITE_ENABLE_UNLOCK_NOTIFY=1"
$CFLAGS += " -DSQLITE_ENABLE_SOUNDEX=1"

$CFLAGS += " -DSQLITE_USE_ALLOCA=1"
$CFLAGS += " -DSQLITE_OMIT_DEPRECATED=1"

# we compile sqlite the same way that the installation of ruby is compiled.
if RbConfig::MAKEFILE_CONFIG['configure_args'].include?( "--enable-pthread" ) then
  $CFLAGS += " -DSQLITE_THREADSAFE=1"
else
  $CFLAGS += " -DSQLITE_THREADSAFE=0"
end

# remove the -g flags  if it exists
%w[ -ggdb\\d* -g\\d* ].each do |debug|
  $CFLAGS = $CFLAGS.gsub(/\s#{debug}\b/,'')
  RbConfig::MAKEFILE_CONFIG['debugflags'] = RbConfig::MAKEFILE_CONFIG['debugflags'].gsub(/\s#{debug}\b/,'')   if RbConfig::MAKEFILE_CONFIG['debugflags']
end

ignoreable_warnings = %w[ write-strings ]
ignore_by_compiler = {
  "clang" => %w[
                  empty-body
                  incompatible-pointer-types-discards-qualifiers
                  shorten-64-to-32
                  sign-compare
                  unused-const-variable
                  unused-variable
                  unused-but-set-variable
                  undef
  ],
  "gcc" => %w[
              declaration-after-statement
              implicit-function-declaration
              unused-variable
              unused-but-set-variable
              maybe-uninitialized
              old-style-definition
              undef
  ]
}

if extras = ignore_by_compiler[RbConfig::MAKEFILE_CONFIG["CC"]] then
  ignoreable_warnings.concat(extras)
end

ignoreable_warnings.each do |warning|
  $CFLAGS = $CFLAGS.gsub(/-W#{warning}/,'')
  RbConfig::MAKEFILE_CONFIG['warnflags'] = RbConfig::MAKEFILE_CONFIG['warnflags'].gsub(/-W#{warning}/,'') if RbConfig::MAKEFILE_CONFIG['warnflags']
  $CFLAGS += " -Wno-#{warning}"
end

subdir = RUBY_VERSION.sub(/\.\d$/,'')
create_makefile("amalgalite/#{subdir}/amalgalite")
