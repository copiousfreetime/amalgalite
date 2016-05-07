#!/usr/bin/env ruby

CONSTANTS = {
  "ResultCode" => {
    "OK"          => "SQLITE_OK",
    "ERROR"       => "SQLITE_ERROR",
    "INTERNAL"    => "SQLITE_INTERNAL",
    "PERM"        => "SQLITE_PERM",
    "ABORT"       => "SQLITE_ABORT",
    "BUSY"        => "SQLITE_BUSY",
    "LOCKED"      => "SQLITE_LOCKED",
    "NOMEM"       => "SQLITE_NOMEM",
    "READONLY"    => "SQLITE_READONLY",
    "INTERRUPT"   => "SQLITE_INTERRUPT",
    "IOERR"       => "SQLITE_IOERR",
    "CORRUPT"     => "SQLITE_CORRUPT",
    "NOTFOUND"    => "SQLITE_NOTFOUND",
    "FULL"        => "SQLITE_FULL",
    "CANTOPEN"    => "SQLITE_CANTOPEN",
    "PROTOCOL"    => "SQLITE_PROTOCOL",
    "EMPTY"       => "SQLITE_EMPTY",
    "SCHEMA"      => "SQLITE_SCHEMA",
    "TOOBIG"      => "SQLITE_TOOBIG",
    "CONSTRAINT"  => "SQLITE_CONSTRAINT",
    "MISMATCH"    => "SQLITE_MISMATCH",
    "MISUSE"      => "SQLITE_MISUSE",
    "NOLFS"       => "SQLITE_NOLFS",
    "AUTH"        => "SQLITE_AUTH",
    "FORMAT"      => "SQLITE_FORMAT",
    "RANGE"       => "SQLITE_RANGE",
    "NOTADB"      => "SQLITE_NOTADB",
    "NOTICE"      => "SQLITE_NOTICE",
    "WARNING"     => "SQLITE_WARNING",
    "ROW"         => "SQLITE_ROW",
    "DONE"        => "SQLITE_DONE",

    "IOERR_READ"              => "SQLITE_IOERR_READ",
    "IOERR_SHORT_READ"        => "SQLITE_IOERR_SHORT_READ",
    "IOERR_WRITE"             => "SQLITE_IOERR_WRITE",
    "IOERR_FSYNC"             => "SQLITE_IOERR_FSYNC",
    "IOERR_DIR_FSYNC"         => "SQLITE_IOERR_DIR_FSYNC",
    "IOERR_TRUNCATE"          => "SQLITE_IOERR_TRUNCATE",
    "IOERR_FSTAT"             => "SQLITE_IOERR_FSTAT",
    "IOERR_UNLOCK"            => "SQLITE_IOERR_UNLOCK",
    "IOERR_RDLOCK"            => "SQLITE_IOERR_RDLOCK",
    "IOERR_DELETE"            => "SQLITE_IOERR_DELETE",
    "IOERR_BLOCKED"           => "SQLITE_IOERR_BLOCKED",
    "IOERR_NOMEM"             => "SQLITE_IOERR_NOMEM",
    "IOERR_ACCESS"            => "SQLITE_IOERR_ACCESS",
    "IOERR_CHECKRESERVEDLOCK" => "SQLITE_IOERR_CHECKRESERVEDLOCK",
    "IOERR_LOCK"              => "SQLITE_IOERR_LOCK",
    "IOERR_CLOSE"             => "SQLITE_IOERR_CLOSE",
    "IOERR_DIR_CLOSE"         => "SQLITE_IOERR_DIR_CLOSE",
    "IOERR_SHMOPEN"           => "SQLITE_IOERR_SHMOPEN",
    "IOERR_SHMSIZE"           => "SQLITE_IOERR_SHMSIZE",
    "IOERR_SHMLOCK"           => "SQLITE_IOERR_SHMLOCK",
    "IOERR_SHMMAP"            => "SQLITE_IOERR_SHMMAP",
    "IOERR_SEEK"              => "SQLITE_IOERR_SEEK",
    "IOERR_DELETE_NOENT"      => "SQLITE_IOERR_DELETE_NOENT",
    "IOERR_MMAP"              => "SQLITE_IOERR_MMAP",
    "IOERR_GETTEMPPATH"       => "SQLITE_IOERR_GETTEMPPATH",
    "IOERR_CONVPATH"          => "SQLITE_IOERR_CONVPATH",
    "IOERR_VNODE"             => "SQLITE_IOERR_VNODE",
    "IOERR_AUTH"              => "SQLITE_IOERR_AUTH",
    "LOCKED_SHAREDCACHE"      => "SQLITE_LOCKED_SHAREDCACHE",
    "BUSY_RECOVERY"           => "SQLITE_BUSY_RECOVERY",
    "BUSY_SNAPSHOT"           => "SQLITE_BUSY_SNAPSHOT",
    "CANTOPEN_NOTEMPDIR"      => "SQLITE_CANTOPEN_NOTEMPDIR",
    "CANTOPEN_ISDIR"          => "SQLITE_CANTOPEN_ISDIR",
    "CANTOPEN_FULLPATH"       => "SQLITE_CANTOPEN_FULLPATH",
    "CANTOPEN_CONVPATH"       => "SQLITE_CANTOPEN_CONVPATH",
    "CORRUPT_VTAB"            => "SQLITE_CORRUPT_VTAB",
    "READONLY_RECOVERY"       => "SQLITE_READONLY_RECOVERY",
    "READONLY_CANTLOCK"       => "SQLITE_READONLY_CANTLOCK",
    "READONLY_ROLLBACK"       => "SQLITE_READONLY_ROLLBACK",
    "READONLY_DBMOVED"        => "SQLITE_READONLY_DBMOVED",
    "ABORT_ROLLBACK"          => "SQLITE_ABORT_ROLLBACK",
    "CONSTRAINT_CHECK"        => "SQLITE_CONSTRAINT_CHECK",
    "CONSTRAINT_COMMITHOOK"   => "SQLITE_CONSTRAINT_COMMITHOOK",
    "CONSTRAINT_FOREIGNKEY"   => "SQLITE_CONSTRAINT_FOREIGNKEY",
    "CONSTRAINT_FUNCTION"     => "SQLITE_CONSTRAINT_FUNCTION",
    "CONSTRAINT_NOTNULL"      => "SQLITE_CONSTRAINT_NOTNULL",
    "CONSTRAINT_PRIMARYKEY"   => "SQLITE_CONSTRAINT_PRIMARYKEY",
    "CONSTRAINT_TRIGGER"      => "SQLITE_CONSTRAINT_TRIGGER",
    "CONSTRAINT_UNIQUE"       => "SQLITE_CONSTRAINT_UNIQUE",
    "CONSTRAINT_VTAB"         => "SQLITE_CONSTRAINT_VTAB",
    "CONSTRAINT_ROWID"        => "SQLITE_CONSTRAINT_ROWID",
    "NOTICE_RECOVER_WAL"      => "SQLITE_NOTICE_RECOVER_WAL",
    "NOTICE_RECOVER_ROLLBACK" => "SQLITE_NOTICE_RECOVER_ROLLBACK",
    "WARNING_AUTOINDEX"       => "SQLITE_WARNING_AUTOINDEX",
    "AUTH_USER"               => "SQLITE_AUTH_USER"
  },


  "DataType" => {
    "INTEGER"   => "SQLITE_INTEGER",
    "FLOAT"     => "SQLITE_FLOAT",
    "BLOB"      => "SQLITE_BLOB",
    "NULL"      => "SQLITE_NULL",
    "TEXT"      => "SQLITE_TEXT",
  },

  "Config"                => {
    "SINGLETHREAD"        => "SQLITE_CONFIG_SINGLETHREAD",
    "MULTITHREAD"         => "SQLITE_CONFIG_MULTITHREAD",
    "SERIALIZED"          => "SQLITE_CONFIG_SERIALIZED",
    "MALLOC"              => "SQLITE_CONFIG_MALLOC",
    "GETMALLOC"           => "SQLITE_CONFIG_GETMALLOC",
    "SCRATCH"             => "SQLITE_CONFIG_SCRATCH",
    "PAGECACHE"           => "SQLITE_CONFIG_PAGECACHE",
    "HEAP"                => "SQLITE_CONFIG_HEAP",
    "MEMSTATUS"           => "SQLITE_CONFIG_MEMSTATUS",
    "MUTEX"               => "SQLITE_CONFIG_MUTEX",
    "GETMUTEX"            => "SQLITE_CONFIG_GETMUTEX",
    "LOOKASIDE"           => "SQLITE_CONFIG_LOOKASIDE",
    "PCACHE"              => "SQLITE_CONFIG_PCACHE",
    "GETPCACHE"           => "SQLITE_CONFIG_GETPCACHE",
    "LOG"                 => "SQLITE_CONFIG_LOG",
    "URI"                 => "SQLITE_CONFIG_URI",
    "PCACHE2"             => "SQLITE_CONFIG_PCACHE2",
    "GETPCACHE2"          => "SQLITE_CONFIG_GETPCACHE2",
    "COVERING_INDEX_SCAN" => "SQLITE_CONFIG_COVERING_INDEX_SCAN",
    "SQLLOG"              => "SQLITE_CONFIG_SQLLOG",
    "MMAP_SIZE"           => "SQLITE_CONFIG_MMAP_SIZE",
    "WIN32_HEAPSIZE"      => "SQLITE_CONFIG_WIN32_HEAPSIZE",
    "PCACHE_HDRSZ"        => "SQLITE_CONFIG_PCACHE_HDRSZ",
    "PMASZ"               => "SQLITE_CONFIG_PMASZ",
    "STMTJRNL_SPILL"      => "SQLITE_CONFIG_STMTJRNL_SPILL",

  },

  "Open" => {
    "READONLY"        => "SQLITE_OPEN_READONLY",
    "READWRITE"       => "SQLITE_OPEN_READWRITE",
    "CREATE"          => "SQLITE_OPEN_CREATE",
    "DELETEONCLOSE"   => "SQLITE_OPEN_DELETEONCLOSE",
    "EXCLUSIVE"       => "SQLITE_OPEN_EXCLUSIVE",
    "AUTOPROXY"       => "SQLITE_OPEN_AUTOPROXY",
    "URI"             => "SQLITE_OPEN_URI",
    "MEMORY"          => "SQLITE_OPEN_MEMORY",
    "MAIN_DB"         => "SQLITE_OPEN_MAIN_DB",
    "TEMP_DB"         => "SQLITE_OPEN_TEMP_DB",
    "TRANSIENT_DB"    => "SQLITE_OPEN_TRANSIENT_DB",
    "MAIN_JOURNAL"    => "SQLITE_OPEN_MAIN_JOURNAL",
    "TEMP_JOURNAL"    => "SQLITE_OPEN_TEMP_JOURNAL",
    "SUBJOURNAL"      => "SQLITE_OPEN_SUBJOURNAL",
    "MASTER_JOURNAL"  => "SQLITE_OPEN_MASTER_JOURNAL",
    "NOMUTEX"         => "SQLITE_OPEN_NOMUTEX",
    "FULLMUTEX"       => "SQLITE_OPEN_FULLMUTEX",
    "SHAREDCACHE"     => "SQLITE_OPEN_SHAREDCACHE",
    "PRIVATECACHE"    => "SQLITE_OPEN_PRIVATECACHE",
    "WAL"             => "SQLITE_OPEN_WAL",
  },

  "Status" => {
    "MEMORY_USED"         => "SQLITE_STATUS_MEMORY_USED",
    "PAGECACHE_USED"      => "SQLITE_STATUS_PAGECACHE_USED",
    "PAGECACHE_OVERFLOW"  => "SQLITE_STATUS_PAGECACHE_OVERFLOW",
    "SCRATCH_USED"        => "SQLITE_STATUS_SCRATCH_USED",
    "SCRATCH_OVERFLOW"    => "SQLITE_STATUS_SCRATCH_OVERFLOW",
    "MALLOC_SIZE"         => "SQLITE_STATUS_MALLOC_SIZE",
    "PARSER_STACK"        => "SQLITE_STATUS_PARSER_STACK",
    "PAGECACHE_SIZE"      => "SQLITE_STATUS_PAGECACHE_SIZE",
    "SCRATCH_SIZE"        => "SQLITE_STATUS_SCRATCH_SIZE",
    "MALLOC_COUNT"        => "SQLITE_STATUS_MALLOC_COUNT",
  },

  "DBStatus" => {
    "LOOKASIDE_USED"      => "SQLITE_DBSTATUS_LOOKASIDE_USED",
    "CACHE_USED"          => "SQLITE_DBSTATUS_CACHE_USED",
    "SCHEMA_USED"         => "SQLITE_DBSTATUS_SCHEMA_USED",
    "STMT_USED"           => "SQLITE_DBSTATUS_STMT_USED",
    "MAX"                 => "SQLITE_DBSTATUS_MAX",
    "LOOKASIDE_HIT"       => "SQLITE_DBSTATUS_LOOKASIDE_HIT",
    "LOOKASIDE_MISS_SIZE" => "SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE",
    "LOOKASIDE_MISS_FULL" => "SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL",
    "CACHE_HIT"           => "SQLITE_DBSTATUS_CACHE_HIT",
    "CACHE_MISS"          => "SQLITE_DBSTATUS_CACHE_MISS",
    "CACHE_WRITE"         => "SQLITE_DBSTATUS_CACHE_WRITE",
    "DEFERRED_FKS"        => "SQLITE_DBSTATUS_DEFERRED_FKS",
  },

  "StatementStatus" => {
    "FULLSCAN_STEP"   => "SQLITE_STMTSTATUS_FULLSCAN_STEP",
    "SORT"            => "SQLITE_STMTSTATUS_SORT",
    "AUTOINDEX"       => "SQLITE_STMTSTATUS_AUTOINDEX",
    "VM_STEP"         => "SQLITE_STMTSTATUS_VM_STEP",
  }

}

fname = File.expand_path(File.join(File.dirname(__FILE__), "amalgalite_constants.c"))
File.open(fname, "w+") do |f|
  f.puts "/* Generated by gen_constants.rb -- do not edit */"
  f.puts
  f.puts '#include "amalgalite.h"'
  f.puts '/**'
  f.puts ' * Document-class: Amalgalite::SQLite3::Constants'
  f.puts ' *'
  f.puts ' * class holding constants in the sqlite extension'
  f.puts ' */'
  f.puts "void Init_amalgalite_constants( )"
  f.puts "{"
  f.puts
  f.puts '    VALUE ma  = rb_define_module("Amalgalite");'
  f.puts '    VALUE mas = rb_define_module_under(ma, "SQLite3");'
  f.puts
  f.puts "    /*"
  f.puts "     * module encapsulating all the SQLite C extension constants "
  f.puts "     */"
  f.puts '    VALUE mC = rb_define_module_under( mas, "Constants");'


  error_code_lines = {}
  IO.readlines("sqlite3.h").each do |l|
    if l =~ /beginning-of-error-codes/ .. l =~ /end-of-error-codes/ then
      next if l =~ /of-error-codes/
      l.strip!
      md = l.match(/\A#define\s+(\w+)\s+(\d+)\s+\/\*(.*)\*\/\Z/)
      error_code_lines[md[1]] = { 'value' => md[2].strip, 'meaning' => md[3].strip } 
    end
  end

  CONSTANTS.keys.sort.each do |klass|
    const_set = CONSTANTS[klass]
    f.puts "    /**"
    f.puts "     * module encapsulating the SQLite3 C extension constants for #{klass}"
    f.puts "     */"
    f.puts "    VALUE mC_#{klass} = rb_define_module_under(mC, \"#{klass}\");"
    f.puts 
  end

  CONSTANTS.keys.sort.each do |klass|
    const_set = CONSTANTS[klass]
    const_set.keys.sort.each do |k|
      sql_const = const_set[k]
      const_doc = "    /* no meaningful autogenerated documentation -- constant is self explanatory ?*/" 
      if ecl = error_code_lines[sql_const] then
        const_doc = "    /*  #{ecl['value']} -- #{ecl['meaning']} */"
      end
      f.puts const_doc
      f.puts "    rb_define_const(mC_#{klass}, \"#{k}\", INT2FIX(#{sql_const}));"
      f.puts  
    end
  end
  f.puts "}"
end
