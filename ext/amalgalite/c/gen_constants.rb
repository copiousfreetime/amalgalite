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
    "ROW"         => "SQLITE_ROW",
    "DONE"        => "SQLITE_DONE",

    "IOERR_READ"                => "SQLITE_IOERR_READ",
    "IOERR_SHORT_READ"          => "SQLITE_IOERR_SHORT_READ",
    "IOERR_WRITE"               => "SQLITE_IOERR_WRITE",
    "IOERR_FSYNC"               => "SQLITE_IOERR_FSYNC",
    "IOERR_DIR_FSYNC"           => "SQLITE_IOERR_DIR_FSYNC",
    "IOERR_TRUNCATE"            => "SQLITE_IOERR_TRUNCATE",
    "IOERR_FSTAT"               => "SQLITE_IOERR_FSTAT",
    "IOERR_UNLOCK"              => "SQLITE_IOERR_UNLOCK",
    "IOERR_RDLOCK"              => "SQLITE_IOERR_RDLOCK",
    "IOERR_DELETE"              => "SQLITE_IOERR_DELETE",
    "IOERR_BLOCKED"             => "SQLITE_IOERR_BLOCKED",
    "IOERR_NOMEM"               => "SQLITE_IOERR_NOMEM",
    "IOERR_ACCESS"              => "SQLITE_IOERR_ACCESS",
    "IOERR_CHECKRESERVEDLOCK"   => "SQLITE_IOERR_CHECKRESERVEDLOCK",
    "IOERR_LOCK"                => "SQLITE_IOERR_LOCK",
    "IOERR_CLOSE"               => "SQLITE_IOERR_CLOSE",
    "IOERR_DIR_CLOSE"           => "SQLITE_IOERR_DIR_CLOSE",
    "IOERR_SHMOPEN"             => "SQLITE_IOERR_SHMOPEN",
    "IOERR_SHMSIZE"             => "SQLITE_IOERR_SHMSIZE",
    "IOERR_SHMLOCK"             => "SQLITE_IOERR_SHMLOCK",

    "LOCKED_SHAREDCACHE"  => "SQLITE_LOCKED_SHAREDCACHE",
    "BUSY_RECOVERY"       => "SQLITE_BUSY_RECOVERY",
    "CANTOPEN_NOTEMPDIR"  => "SQLITE_CANTOPEN_NOTEMPDIR",
  },


  "DataType" => {
    "INTEGER"   => "SQLITE_INTEGER",
    "FLOAT"     => "SQLITE_FLOAT",
    "BLOB"      => "SQLITE_BLOB",
    "NULL"      => "SQLITE_NULL",
    "TEXT"      => "SQLITE_TEXT",
  },

  "Config" => {
    "SINGLETHREAD"  => "SQLITE_CONFIG_SINGLETHREAD",
    "MULTITHREAD"   => "SQLITE_CONFIG_MULTITHREAD",
    "SERIALIZED"    => "SQLITE_CONFIG_SERIALIZED",
    "MALLOC"        => "SQLITE_CONFIG_MALLOC",
    "GETMALLOC"     => "SQLITE_CONFIG_GETMALLOC",
    "SCRATCH"       => "SQLITE_CONFIG_SCRATCH",
    "PAGECACHE"     => "SQLITE_CONFIG_PAGECACHE",
    "HEAP"          => "SQLITE_CONFIG_HEAP",
    "MEMSTATUS"     => "SQLITE_CONFIG_MEMSTATUS",
    "MUTEX"         => "SQLITE_CONFIG_MUTEX",
    "GETMUTEX"      => "SQLITE_CONFIG_GETMUTEX",
    "LOOKASIDE"     => "SQLITE_CONFIG_LOOKASIDE",
    "PCACHE"        => "SQLITE_CONFIG_PCACHE",
    "GETPCACHE"     => "SQLITE_CONFIG_GETPCACHE",
    "LOG"           => "SQLITE_CONFIG_LOG",
  },

  "Open" => {
    "READONLY"        => "SQLITE_OPEN_READONLY",
    "READWRITE"       => "SQLITE_OPEN_READWRITE",
    "CREATE"          => "SQLITE_OPEN_CREATE",
    "DELETEONCLOSE"   => "SQLITE_OPEN_DELETEONCLOSE",
    "EXCLUSIVE"       => "SQLITE_OPEN_EXCLUSIVE",
    "AUTOPROXY"       => "SQLITE_OPEN_AUTOPROXY",
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
    "LOOKASIDE_USED" => "SQLITE_DBSTATUS_LOOKASIDE_USED",
    "CACHE_USED"     => "SQLITE_DBSTATUS_CACHE_USED",
    "SCHEMA_USED"    => "SQLITE_DBSTATUS_SCHEMA_USED",
    "STMT_USED"      => "SQLITE_DBSTATUS_STMT_USED",
    "MAX"            => "SQLITE_DBSTATUS_MAX",
  },

  "StatementStatus" => {
    "FULLSCAN_STEP"   => "SQLITE_STMTSTATUS_FULLSCAN_STEP",
    "SORT"            => "SQLITE_STMTSTATUS_SORT",
    "AUTOINDEX"       => "SQLITE_STMTSTATUS_AUTOINDEX",
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
