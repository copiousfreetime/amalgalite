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
    "IOERR_BEGIN_ATOMIC"      => "SQLITE_IOERR_BEGIN_ATOMIC",
    "IOERR_COMMIT_ATOMIC"     => "SQLITE_IOERR_COMMIT_ATOMIC",
    "IOERR_ROLLBACK_ATOMIC"   => "SQLITE_IOERR_ROLLBACK_ATOMIC",
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
    "AUTH_USER"               => "SQLITE_AUTH_USER",
    "OK_LOAD_PERMANENTLY"     => "SQLITE_OK_LOAD_PERMANENTLY",
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
    # "CHUNKALLOC"          => "SQLITE_CONFIG_CHUNKALLOC", - no longer used
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
    "SMALL_MALLOC"        => "SQLITE_CONFIG_SMALL_MALLOC",
  },

  "DBConfig" => {
    "MAINDBNAME"            => "SQLITE_DBCONFIG_MAINDBNAME",
    "LOOKASIDE"             => "SQLITE_DBCONFIG_LOOKASIDE",
    "ENABLE_FKEY"           => "SQLITE_DBCONFIG_ENABLE_FKEY",
    "ENABLE_TRIGGER"        => "SQLITE_DBCONFIG_ENABLE_TRIGGER",
    "ENABLE_FTS3_TOKENIZER" => "SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER",
    "ENABLE_LOAD_EXTENSION" => "SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION",
    "NO_CKPT_ON_CLOSE"      => "SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE",
    "ENABLE_QPSG"           => "SQLITE_DBCONFIG_ENABLE_QPSG",
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

  "IOCap" => {
    "ATOMIC"                => "SQLITE_IOCAP_ATOMIC",
    "ATOMIC512"             => "SQLITE_IOCAP_ATOMIC512",
    "ATOMIC1K"              => "SQLITE_IOCAP_ATOMIC1K",
    "ATOMIC2K"              => "SQLITE_IOCAP_ATOMIC2K",
    "ATOMIC4K"              => "SQLITE_IOCAP_ATOMIC4K",
    "ATOMIC8K"              => "SQLITE_IOCAP_ATOMIC8K",
    "ATOMIC16K"             => "SQLITE_IOCAP_ATOMIC16K",
    "ATOMIC32K"             => "SQLITE_IOCAP_ATOMIC32K",
    "ATOMIC64K"             => "SQLITE_IOCAP_ATOMIC64K",
    "SAFE_APPEND"           => "SQLITE_IOCAP_SAFE_APPEND",
    "SEQUENTIAL"            => "SQLITE_IOCAP_SEQUENTIAL",
    "UNDELETABLE_WHEN_OPEN" => "SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN",
    "POWERSAFE_OVERWRITE"   => "SQLITE_IOCAP_POWERSAFE_OVERWRITE",
    "IMMUTABLE"             => "SQLITE_IOCAP_IMMUTABLE",
    "BATCH_ATOMIC"          => "SQLITE_IOCAP_BATCH_ATOMIC",
  },

  "Lock" => {
    "NONE"      => "SQLITE_LOCK_NONE",
    "SHARED"    => "SQLITE_LOCK_SHARED",
    "RESERVED"  => "SQLITE_LOCK_RESERVED",
    "PENDING"   => "SQLITE_LOCK_PENDING",
    "EXCLUSIVE" => "SQLITE_LOCK_EXCLUSIVE",
  },

  "Sync" => {
    "NORMAL"   => "SQLITE_SYNC_NORMAL",
    "FULL"     => "SQLITE_SYNC_FULL",
    "DATAONLY" => "SQLITE_SYNC_DATAONLY",
  },

  "Fcntl" => {
    "LOCKSTATE"             => "SQLITE_FCNTL_LOCKSTATE",
    "GET_LOCKPROXYFILE"     => "SQLITE_FCNTL_GET_LOCKPROXYFILE",
    "SET_LOCKPROXYFILE"     => "SQLITE_FCNTL_SET_LOCKPROXYFILE",
    "LAST_ERRNO"            => "SQLITE_FCNTL_LAST_ERRNO",
    "SIZE_HINT"             => "SQLITE_FCNTL_SIZE_HINT",
    "CHUNK_SIZE"            => "SQLITE_FCNTL_CHUNK_SIZE",
    "FILE_POINTER"          => "SQLITE_FCNTL_FILE_POINTER",
    "SYNC_OMITTED"          => "SQLITE_FCNTL_SYNC_OMITTED",
    "WIN32_AV_RETRY"        => "SQLITE_FCNTL_WIN32_AV_RETRY",
    "PERSIST_WAL"           => "SQLITE_FCNTL_PERSIST_WAL",
    "OVERWRITE"             => "SQLITE_FCNTL_OVERWRITE",
    "VFSNAME"               => "SQLITE_FCNTL_VFSNAME",
    "POWERSAFE_OVERWRITE"   => "SQLITE_FCNTL_POWERSAFE_OVERWRITE",
    "PRAGMA"                => "SQLITE_FCNTL_PRAGMA",
    "BUSYHANDLER"           => "SQLITE_FCNTL_BUSYHANDLER",
    "TEMPFILENAME"          => "SQLITE_FCNTL_TEMPFILENAME",
    "MMAP_SIZE"             => "SQLITE_FCNTL_MMAP_SIZE",
    "TRACE"                 => "SQLITE_FCNTL_TRACE",
    "HAS_MOVED"             => "SQLITE_FCNTL_HAS_MOVED",
    "SYNC"                  => "SQLITE_FCNTL_SYNC",
    "COMMIT_PHASETWO"       => "SQLITE_FCNTL_COMMIT_PHASETWO",
    "WIN32_SET_HANDLE"      => "SQLITE_FCNTL_WIN32_SET_HANDLE",
    "WAL_BLOCK"             => "SQLITE_FCNTL_WAL_BLOCK",
    "ZIPVFS"                => "SQLITE_FCNTL_ZIPVFS",
    "RBU"                   => "SQLITE_FCNTL_RBU",
    "VFS_POINTER"           => "SQLITE_FCNTL_VFS_POINTER",
    "JOURNAL_POINTER"       => "SQLITE_FCNTL_JOURNAL_POINTER",
    "WIN32_GET_HANDLE"      => "SQLITE_FCNTL_WIN32_GET_HANDLE",
    "PDB"                   => "SQLITE_FCNTL_PDB",
    "BEGIN_ATOMIC_WRITE"    => "SQLITE_FCNTL_BEGIN_ATOMIC_WRITE",
    "COMMIT_ATOMIC_WRITE"   => "SQLITE_FCNTL_COMMIT_ATOMIC_WRITE",
    "ROLLBACK_ATOMIC_WRITE" => "SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE",
  },

  "Access" => {
    "EXISTS"    => "SQLITE_ACCESS_EXISTS",
    "READWRITE" => "SQLITE_ACCESS_READWRITE",
    "READ"      => "SQLITE_ACCESS_READ",
  },

  "SHM" => {
    "UNLOCK"    => "SQLITE_SHM_UNLOCK",
    "LOCK"      => "SQLITE_SHM_LOCK",
    "SHARED"    => "SQLITE_SHM_SHARED",
    "EXCLUSIVE" => "SQLITE_SHM_EXCLUSIVE",
    "NLOCK"     => "SQLITE_SHM_NLOCK",
  },

  "Trace" => {
    "STMT"    => "SQLITE_TRACE_STMT",
    "PROFILE" => "SQLITE_TRACE_PROFILE",
    "ROW"     => "SQLITE_TRACE_ROW",
    "CLOSE"   => "SQLITE_TRACE_CLOSE",
  },

  "Limit" => {
    "LENGTH"              => "SQLITE_LIMIT_LENGTH",
    "SQL_LENGTH"          => "SQLITE_LIMIT_SQL_LENGTH",
    "COLUMN"              => "SQLITE_LIMIT_COLUMN",
    "EXPR_DEPTH"          => "SQLITE_LIMIT_EXPR_DEPTH",
    "COMPOUND_SELECT"     => "SQLITE_LIMIT_COMPOUND_SELECT",
    "VDBE_OP"             => "SQLITE_LIMIT_VDBE_OP",
    "FUNCTION_ARG"        => "SQLITE_LIMIT_FUNCTION_ARG",
    "ATTACHED"            => "SQLITE_LIMIT_ATTACHED",
    "LIKE_PATTERN_LENGTH" => "SQLITE_LIMIT_LIKE_PATTERN_LENGTH",
    "VARIABLE_NUMBER"     => "SQLITE_LIMIT_VARIABLE_NUMBER",
    "TRIGGER_DEPTH"       => "SQLITE_LIMIT_TRIGGER_DEPTH",
    "WORKER_THREADS"      => "SQLITE_LIMIT_WORKER_THREADS",
  },

  "Prepare" => {
    "PERSISTENT" => "SQLITE_PREPARE_PERSISTENT",
  },

  "Index" => {
    "SCAN_UNIQUE"          => "SQLITE_INDEX_SCAN_UNIQUE",
    "CONSTRAINT_EQ"        => "SQLITE_INDEX_CONSTRAINT_EQ",
    "CONSTRAINT_GT"        => "SQLITE_INDEX_CONSTRAINT_GT",
    "CONSTRAINT_LE"        => "SQLITE_INDEX_CONSTRAINT_LE",
    "CONSTRAINT_LT"        => "SQLITE_INDEX_CONSTRAINT_LT",
    "CONSTRAINT_GE"        => "SQLITE_INDEX_CONSTRAINT_GE",
    "CONSTRAINT_MATCH"     => "SQLITE_INDEX_CONSTRAINT_MATCH",
    "CONSTRAINT_LIKE"      => "SQLITE_INDEX_CONSTRAINT_LIKE",
    "CONSTRAINT_GLOB"      => "SQLITE_INDEX_CONSTRAINT_GLOB",
    "CONSTRAINT_REGEXP"    => "SQLITE_INDEX_CONSTRAINT_REGEXP",
    "CONSTRAINT_NE"        => "SQLITE_INDEX_CONSTRAINT_NE",
    "CONSTRAINT_ISNOT"     => "SQLITE_INDEX_CONSTRAINT_ISNOT",
    "CONSTRAINT_ISNOTNULL" => "SQLITE_INDEX_CONSTRAINT_ISNOTNULL",
    "CONSTRAINT_ISNULL"    => "SQLITE_INDEX_CONSTRAINT_ISNULL",
    "CONSTRAINT_IS"        => "SQLITE_INDEX_CONSTRAINT_IS",
  },

  "Mutex" => {
    "FAST"          => "SQLITE_MUTEX_FAST",
    "RECURSIVE"     => "SQLITE_MUTEX_RECURSIVE",
    "STATIC_MASTER" => "SQLITE_MUTEX_STATIC_MASTER",
    "STATIC_MEM"    => "SQLITE_MUTEX_STATIC_MEM",
    "STATIC_MEM2"   => "SQLITE_MUTEX_STATIC_MEM2",
    "STATIC_OPEN"   => "SQLITE_MUTEX_STATIC_OPEN",
    "STATIC_PRNG"   => "SQLITE_MUTEX_STATIC_PRNG",
    "STATIC_LRU"    => "SQLITE_MUTEX_STATIC_LRU",
    "STATIC_LRU2"   => "SQLITE_MUTEX_STATIC_LRU2",
    "STATIC_PMEM"   => "SQLITE_MUTEX_STATIC_PMEM",
    "STATIC_APP1"   => "SQLITE_MUTEX_STATIC_APP1",
    "STATIC_APP2"   => "SQLITE_MUTEX_STATIC_APP2",
    "STATIC_APP3"   => "SQLITE_MUTEX_STATIC_APP3",
    "STATIC_VFS1"   => "SQLITE_MUTEX_STATIC_VFS1",
    "STATIC_VFS2"   => "SQLITE_MUTEX_STATIC_VFS2",
    "STATIC_VFS3"   => "SQLITE_MUTEX_STATIC_VFS3",
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
    "LOOKASIDE_HIT"       => "SQLITE_DBSTATUS_LOOKASIDE_HIT",
    "LOOKASIDE_MISS_SIZE" => "SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE",
    "LOOKASIDE_MISS_FULL" => "SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL",
    "CACHE_HIT"           => "SQLITE_DBSTATUS_CACHE_HIT",
    "CACHE_MISS"          => "SQLITE_DBSTATUS_CACHE_MISS",
    "CACHE_WRITE"         => "SQLITE_DBSTATUS_CACHE_WRITE",
    "DEFERRED_FKS"        => "SQLITE_DBSTATUS_DEFERRED_FKS",
    "CACHE_USED_SHARED"   => "SQLITE_DBSTATUS_CACHE_USED_SHARED",
    "MAX"                 => "SQLITE_DBSTATUS_MAX",
  },

  "StatementStatus" => {
    "FULLSCAN_STEP"   => "SQLITE_STMTSTATUS_FULLSCAN_STEP",
    "SORT"            => "SQLITE_STMTSTATUS_SORT",
    "AUTOINDEX"       => "SQLITE_STMTSTATUS_AUTOINDEX",
    "VM_STEP"         => "SQLITE_STMTSTATUS_VM_STEP",
    "REPREPARE"       => "SQLITE_STMTSTATUS_REPREPARE",
    "RUN"             => "SQLITE_STMTSTATUS_RUN",
    "MEMUSED"         => "SQLITE_STMTSTATUS_MEMUSED",
  },

  "Checkpoint" => {
    "PASSIVE"  => "SQLITE_CHECKPOINT_PASSIVE",
    "FULL"     => "SQLITE_CHECKPOINT_FULL",
    "RESTART"  => "SQLITE_CHECKPOINT_RESTART",
    "TRUNCATE" => "SQLITE_CHECKPOINT_TRUNCATE",
  },

  "ScanStat" => {
    "NLOOP"    => "SQLITE_SCANSTAT_NLOOP",
    "NVISIT"   => "SQLITE_SCANSTAT_NVISIT",
    "EST"      => "SQLITE_SCANSTAT_EST",
    "NAME"     => "SQLITE_SCANSTAT_NAME",
    "EXPLAIN"  => "SQLITE_SCANSTAT_EXPLAIN",
    "SELECTID" => "SQLITE_SCANSTAT_SELECTID",
  },

  "RTree" => {
    "NOT_WITHIN"    => "NOT_WITHIN",
    "PARTLY_WITHIN" => "PARTLY_WITHIN",
    "FULLY_WITHIN"  => "FULLY_WITHIN",
  },

  "FTS5" => {
    "TOKENIZE_QUERY"    => "FTS5_TOKENIZE_QUERY",
    "TOKENIZE_PREFIX"   => "FTS5_TOKENIZE_PREFIX",
    "TOKENIZE_DOCUMENT" => "FTS5_TOKENIZE_DOCUMENT",
    "TOKENIZE_AUX"      => "FTS5_TOKENIZE_AUX",
    "TOKEN_COLOCATED"   => "FTS5_TOKEN_COLOCATED",
  },

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
