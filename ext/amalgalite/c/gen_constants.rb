#!/usr/bin/env ruby

require 'pp'

# readin in the sqlite3.h file and parse out all the #define lines
sqlite3_h_fname = File.expand_path(File.join(File.dirname(__FILE__), "sqlite3.h"))

# special handling for those that are function result codes
result_codes = %w[
  SQLITE_OK
  SQLITE_ERROR
  SQLITE_INTERNAL
  SQLITE_PERM
  SQLITE_ABORT
  SQLITE_BUSY
  SQLITE_LOCKED
  SQLITE_NOMEM
  SQLITE_READONLY
  SQLITE_INTERRUPT
  SQLITE_IOERR
  SQLITE_CORRUPT
  SQLITE_NOTFOUND
  SQLITE_FULL
  SQLITE_CANTOPEN
  SQLITE_PROTOCOL
  SQLITE_EMPTY
  SQLITE_SCHEMA
  SQLITE_TOOBIG
  SQLITE_CONSTRAINT
  SQLITE_MISMATCH
  SQLITE_MISUSE
  SQLITE_NOLFS
  SQLITE_AUTH
  SQLITE_FORMAT
  SQLITE_RANGE
  SQLITE_NOTADB
  SQLITE_NOTICE
  SQLITE_WARNING
  SQLITE_ROW
  SQLITE_DONE
  SQLITE_ERROR_MISSING_COLLSEQ
  SQLITE_ERROR_RETRY
  SQLITE_ERROR_SNAPSHOT
  SQLITE_IOERR_READ
  SQLITE_IOERR_SHORT_READ
  SQLITE_IOERR_WRITE
  SQLITE_IOERR_FSYNC
  SQLITE_IOERR_DIR_FSYNC
  SQLITE_IOERR_TRUNCATE
  SQLITE_IOERR_FSTAT
  SQLITE_IOERR_UNLOCK
  SQLITE_IOERR_RDLOCK
  SQLITE_IOERR_DELETE
  SQLITE_IOERR_BLOCKED
  SQLITE_IOERR_NOMEM
  SQLITE_IOERR_ACCESS
  SQLITE_IOERR_CHECKRESERVEDLOCK
  SQLITE_IOERR_LOCK
  SQLITE_IOERR_CLOSE
  SQLITE_IOERR_DIR_CLOSE
  SQLITE_IOERR_SHMOPEN
  SQLITE_IOERR_SHMSIZE
  SQLITE_IOERR_SHMLOCK
  SQLITE_IOERR_SHMMAP
  SQLITE_IOERR_SEEK
  SQLITE_IOERR_DELETE_NOENT
  SQLITE_IOERR_MMAP
  SQLITE_IOERR_GETTEMPPATH
  SQLITE_IOERR_CONVPATH
  SQLITE_IOERR_VNODE
  SQLITE_IOERR_AUTH
  SQLITE_IOERR_BEGIN_ATOMIC
  SQLITE_IOERR_COMMIT_ATOMIC
  SQLITE_IOERR_ROLLBACK_ATOMIC
  SQLITE_IOERR_DATA
  SQLITE_IOERR_CORRUPTFS
  SQLITE_LOCKED_SHAREDCACHE
  SQLITE_LOCKED_VTAB
  SQLITE_BUSY_RECOVERY
  SQLITE_BUSY_SNAPSHOT
  SQLITE_BUSY_TIMEOUT
  SQLITE_CANTOPEN_NOTEMPDIR
  SQLITE_CANTOPEN_ISDIR
  SQLITE_CANTOPEN_FULLPATH
  SQLITE_CANTOPEN_CONVPATH
  SQLITE_CANTOPEN_DIRTYWAL
  SQLITE_CANTOPEN_SYMLINK
  SQLITE_CORRUPT_VTAB
  SQLITE_CORRUPT_SEQUENCE
  SQLITE_CORRUPT_INDEX
  SQLITE_READONLY_RECOVERY
  SQLITE_READONLY_CANTLOCK
  SQLITE_READONLY_ROLLBACK
  SQLITE_READONLY_DBMOVED
  SQLITE_READONLY_CANTINIT
  SQLITE_READONLY_DIRECTORY
  SQLITE_ABORT_ROLLBACK
  SQLITE_CONSTRAINT_CHECK
  SQLITE_CONSTRAINT_COMMITHOOK
  SQLITE_CONSTRAINT_FOREIGNKEY
  SQLITE_CONSTRAINT_FUNCTION
  SQLITE_CONSTRAINT_NOTNULL
  SQLITE_CONSTRAINT_PRIMARYKEY
  SQLITE_CONSTRAINT_TRIGGER
  SQLITE_CONSTRAINT_UNIQUE
  SQLITE_CONSTRAINT_VTAB
  SQLITE_CONSTRAINT_ROWID
  SQLITE_CONSTRAINT_PINNED
  SQLITE_NOTICE_RECOVER_WAL
  SQLITE_NOTICE_RECOVER_ROLLBACK
  SQLITE_WARNING_AUTOINDEX
  SQLITE_AUTH_USER
  SQLITE_OK_LOAD_PERMANENTLY
  SQLITE_OK_SYMLINK
]

deprecated_codes = %w[ SQLITE_GET_LOCKPROXYFILE SQLITE_SET_LOCKPROXYFILE SQLITE_LAST_ERRNO ]
version_codes    = %w[ SQLITE_VERSION SQLITE_VERSION_NUMBER SQLITE_SOURCE_ID ]
rtree_codes      = %w[ NOT_WITHIN PARTLY_WITHIN FULLY_WITHIN ]

authorizer_codes = %w[
  SQLITE_DENY
  SQLITE_IGNORE
  SQLITE_CREATE_INDEX
  SQLITE_CREATE_TABLE
  SQLITE_CREATE_TEMP_INDEX
  SQLITE_CREATE_TEMP_TABLE
  SQLITE_CREATE_TEMP_TRIGGER
  SQLITE_CREATE_TEMP_VIEW
  SQLITE_CREATE_TRIGGER
  SQLITE_CREATE_VIEW
  SQLITE_DELETE
  SQLITE_DROP_INDEX
  SQLITE_DROP_TABLE
  SQLITE_DROP_TEMP_INDEX
  SQLITE_DROP_TEMP_TABLE
  SQLITE_DROP_TEMP_TRIGGER
  SQLITE_DROP_TEMP_VIEW
  SQLITE_DROP_TRIGGER
  SQLITE_DROP_VIEW
  SQLITE_INSERT
  SQLITE_PRAGMA
  SQLITE_READ
  SQLITE_SELECT
  SQLITE_TRANSACTION
  SQLITE_UPDATE
  SQLITE_ATTACH
  SQLITE_DETACH
  SQLITE_ALTER_TABLE
  SQLITE_REINDEX
  SQLITE_ANALYZE
  SQLITE_CREATE_VTABLE
  SQLITE_DROP_VTABLE
  SQLITE_FUNCTION
  SQLITE_SAVEPOINT
  SQLITE_COPY
  SQLITE_RECURSIVE
]

text_encoding_codes = %w[
  SQLITE_UTF8
  SQLITE_UTF16LE
  SQLITE_UTF16BE
  SQLITE_UTF16
  SQLITE_ANY
  SQLITE_UTF16_ALIGNED
  SQLITE_DETERMINISTIC
  SQLITE_DIRECTONLY
  SQLITE_SUBTYPE
  SQLITE_INNOCUOUS
]

data_type_codes = %w[
  SQLITE_INTEGER
  SQLITE_FLOAT
  SQLITE_BLOB
  SQLITE_NULL
  SQLITE3_TEXT
]

fts5_codes = %w[
  FTS5_TOKENIZE_QUERY
  FTS5_TOKENIZE_PREFIX
  FTS5_TOKENIZE_DOCUMENT
  FTS5_TOKENIZE_AUX
  FTS5_TOKEN_COLOCATED
]

ignore_codes = [
  # vtab related
  "SQLITE_ROLLBACK",
  "SQLITE_FAIL",
  "SQLITE_REPLACE",
  "SQLITE_VTAB_CONSTRAINT_SUPPORT",
  "SQLITE_VTAB_INNOCUOUS",
  "SQLITE_VTAB_DIRECTONLY",

  # sqlite destructor callback codes
  "SQLITE_STATIC",
  "SQLITE_TRANSIENT",
]

# oddball name
module_name_mapping  = {

  "DBCONFIG"   => "DBConfig",
  "DBSTATUS"   => "DBStatus",
  "IOCAP"      => "IOCap",
  "SHM"        => "SHM",
  "SCANSTAT"   => "ScanStat",
  "STMTSTATUS" => "StatementStatus",
  "CHANGESETAPPLY" => "ChangesetApply",
  "CHANGESETSTART" => "ChangesetStart",
  "TXN" => "Transaction",
}

defines = []
IO.readlines(sqlite3_h_fname).each do |l|
  result = {
    "c_define"  => nil,
    "c_value"   => nil,
    "docstring" => nil,

    "is_error_code" => false,

    "r_module"   => nil,
    "r_constant" => nil,
  }

  if l =~ /beginning-of-error-codes/ .. l =~ /end-of-error-codes/ then
    result["is_error_code"] = true
  end

  l.strip!
  md = l.match(/\A#define\s+(\w+)\s+([^\/]+)\s*(\/\*(.*)\*\/)?\Z/)
  next unless md

  # Name munging
  c_define = md[1]

  c_parts    = c_define.gsub(/^SQLITE_/,'').split("_")
  r_module   = c_parts.shift
  r_constant = c_parts.join("_")


  # custom module naming so they are human readable
  r_module = module_name_mapping.fetch(r_module) { |m| r_module.capitalize }

  case c_define
  when *version_codes
    next

  when *deprecated_codes
    next

  when *rtree_codes
    r_module = "RTree"
    r_constant = c_define

  when *result_codes
    r_module   = "ResultCode"
    r_constant = c_define.gsub(/^SQLITE_/,'')

  when *authorizer_codes
    r_module   = "Authorizer"
    r_constant = c_define.gsub(/^SQLITE_/,'')

  when *text_encoding_codes
    r_module   = "TextEncoding"
    r_constant = c_define.gsub(/^SQLITE_/,'')

  when *data_type_codes
    r_module = "DataType"
    r_constant = c_define.gsub(/^SQLITE(3)?_/,'')

  when *fts5_codes
    r_module = "FTS5"
    r_constant = c_define.gsub(/^FTS5_/,'')

  when *ignore_codes
    next

  when /TESTCTRL/ # sqlite3 codes used in testing
    next

  when /^__/ # sqlite3 internal items
    next
  end

  result["c_define"]   = c_define
  result["c_value"]    = md[2].strip
  if !md[4].nil? && (md[4].strip.length > 0) then
    result["docstring"]  = md[4].strip
  end
  result["r_module"]   = r_module
  result["r_constant"] = r_constant

  defines << result
end

#
# rework defines into constants
#
CONSTANTS = defines.group_by{ |d| d["r_module"] }

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


  CONSTANTS.keys.sort.each do |mod|
    f.puts "    /**"
    f.puts "     * module encapsulating the SQLite3 C extension constants for #{mod}"
    f.puts "     */"
    f.puts "    VALUE mC_#{mod} = rb_define_module_under(mC, \"#{mod}\");"
    f.puts 
  end

  CONSTANTS.keys.sort.each do |mod|
    const_set = CONSTANTS[mod]
    const_set.sort_by { |c| c["c_define"] }.each do |result|
      sql_const = result["c_define"]
      const_doc = "    /* no meaningful autogenerated documentation -- constant is self explanatory ?*/" 
      if !result["docstring"].nil? then
        const_doc = "    /*  #{result['c_value']} -- #{result['docstring']} */"
      end
      ruby_constant = result['r_constant']
      f.puts const_doc
      f.puts "    rb_define_const(mC_#{mod}, \"#{ruby_constant}\", INT2FIX(#{sql_const}));"
      f.puts  
    end
  end
  f.puts "}"
end
