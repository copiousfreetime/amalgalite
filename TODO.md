# Future Release possibilties:
- rebuild statement constants
- look at all pragma statements

## SQLite API:
- authorizers
- loading of extensions -- readfile / writefile
- utf-16 integration
- create_collation 
- encryption key support
- expose sqlite3_strnicmp
- table name and column name in a type map?
- type conversion for manifest typing? how to allow it through?
- explicit pragma handler
- application_id pragma setter

## Non backwards compatible changes:
- change the schema objects to be more consistent
- change taps to use to_proc protocol
- convert type dependency to just use 'call'
- integrate transaction and savepoint under the same api

## SQLite Features:
- activate SQLITE_ENABLE_ICU extension
- activate SQLITE_ENABLE_LOCKING_STYLE
- activate SQLITE_ENABLE_UNLOCK_NOTIFY
- expose PRAGMA foreign_keys
- virtual file system
- full text search (FTS3)
- expose the sqlite mutex lib
- statement status ( sqlite3_stmt_status )
- db status ( sqlite3_db_status )
- library status ( sqlite3_status )
- sqlite3_index_info
- sqlite3_create_function has 4th parameter SQLITE_DETERMINISTIC 
- sqlite3_rtree_query_callback()

## Drivers:
- data mapper driver
- sequel driver optimization

## Features:
- add to command line which directory to pack into a rubylibs table
- amalgalite command line tool
- use ruby's ALLOC_N and hook into sqlite3_mem_methods

## Functions to possibly expose:
- sqlite3_backup_remaining, sqlite3_backup_pagecount
- sqlite3_compileoption_used, sqlite3_compileoption_get
- sqlite3_config
- sqlite3_data_count - returns number of colums in the result set of a
  prepared statement
- sqlite_sourceid, sqlite_source_id
- sqlite3_strnicmp
