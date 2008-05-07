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

    "IOERR_READ"        => "SQLITE_IOERR_READ",
    "IOERR_SHORT_READ"  => "SQLITE_IOERR_SHORT_READ",
    "IOERR_WRITE"       => "SQLITE_IOERR_WRITE",
    "IOERR_FSYNC"       => "SQLITE_IOERR_FSYNC",
    "IOERR_DIR_FSYNC"   => "SQLITE_IOERR_DIR_FSYNC",
    "IOERR_TRUNCATE"    => "SQLITE_IOERR_TRUNCATE",
    "IOERR_FSTAT"       => "SQLITE_IOERR_FSTAT",
    "IOERR_UNLOCK"      => "SQLITE_IOERR_UNLOCK",
    "IOERR_RDLOCK"      => "SQLITE_IOERR_RDLOCK",
    "IOERR_DELETE"      => "SQLITE_IOERR_DELETE",
    "IOERR_BLOCKED"     => "SQLITE_IOERR_BLOCKED",
    "IOERR_NOMEM"       => "SQLITE_IOERR_NOMEM",
  },


  "DataType" => {
    "INTEGER"   => "SQLITE_INTEGER",
    "FLOAT"     => "SQLITE_FLOAT",
    "BLOB"      => "SQLITE_BLOB",
    "NULL"      => "SQLITE_NULL",
    "TEXT"      => "SQLITE_TEXT",
  },

  "Open" => {
    "READONLY"  => "SQLITE_OPEN_READONLY",
    "READWRITE" => "SQLITE_OPEN_READWRITE",
    "CREATE"    => "SQLITE_OPEN_CREATE",
  },
}

fname = File.expand_path(File.join(File.dirname(__FILE__), "amalgalite3_constants.c"))
File.open(fname, "w+") do |f|
  f.puts "/* Generated code do not edit */"
  f.puts
  f.puts '#include "amalgalite3.h";'
  f.puts "void am_define_constants_under(VALUE module)"
  f.puts "{"
  f.puts '    VALUE mC = rb_define_module_under(module, "Constants");'

  CONSTANTS.each_pair do |klass, const_set|
    f.puts
    f.puts "    VALUE mC_#{klass} = rb_define_module_under(mC, \"#{klass}\");"
    const_set.each_pair do |k, sql_const|
      f.puts "    rb_define_const(mC_#{klass}, \"#{k}\", INT2FIX(#{sql_const}));"
    end
  end
  f.puts "}"
end
