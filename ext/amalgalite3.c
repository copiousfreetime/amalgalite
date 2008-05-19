#include "amalgalite3.h"
/* 
 * vim: shiftwidth=4 
 */ 

/***********************************************************************
 * Prototypes
 ***********************************************************************/

/* Module and Classes */
VALUE mA;
VALUE mAS;
VALUE mASV;
VALUE cAS_Database;
VALUE cAS_Statement;
VALUE eAS_Error;

/*
 * Return the sqlite3 version number as a string
 *
 * :call-seq:
 *    Amalgalite::SQLite3.version -> String
 */
VALUE am_sqlite3_libversion(VALUE self)
{
    return rb_str_new2(sqlite3_libversion());
}

/*
 * Return the sqlite3 version number as an integer
 *
 * :call-seq:
 *    Amalgalite::SQLite3.version_number -> Fixnum
 *
 */
VALUE am_sqlite3_libversion_number(VALUE self)
{
    return INT2FIX(sqlite3_libversion_number());
}

/*
 * Has the SQLite3 extension been compiled "threadsafe".  This is threadsafe? is
 * true then the internal SQLite mutexes are enabled and SQLite is threadsafe.
 * That is, 'C' level threadsafe.
 *
 * :call-seq:
 *    Amalgalite::SQLite3.threadsafe? -> true or false
 *
 */
VALUE am_sqlite3_threadsafe(VALUE self)
{
    if (sqlite3_threadsafe()) {
        return Qtrue;
    } else {
        return Qfalse;
    }
}

/*
 * Is the text passed in as a parameter a complete SQL statement?  Or is
 * additional input required before sending the SQL to the extension.  If the
 * extra 'opts' parameter is used, you can send in a UTF-16 encoded string as
 * the SQL.
 *
 * A complete statement must end with a semicolon.
 *
 * :call-seq:
 *    Amalgalite::SQLite3.complete?( ... , opts = { :utf16 => false }) -> True, False
 *
 */
VALUE am_sqlite3_complete(VALUE self, VALUE args)
{
    VALUE sql      = rb_ary_shift( args );
    VALUE opts     = rb_ary_shift( args );
    VALUE utf16    = Qnil;
    int   result = 0;

    if ( ( Qnil != opts ) && ( T_HASH == TYPE(opts) ) ){
        utf16 = rb_hash_aref( opts, rb_intern("utf16") );
    }

    if ( (Qfalse == utf16) || (Qnil == utf16) ) {
        result = sqlite3_complete( StringValuePtr( sql ) );
    } else {
        result = sqlite3_complete16( (void*) StringValuePtr( sql ) );
    }

    return ( result > 0 ) ? Qtrue : Qfalse;
}

/*
 * Return the number of bytes of memory outstanding in the SQLite extension
 *
 * :call-seq:
 *    Amalgalite::SQLite3.memory_used -> Numeric
 *
 */
VALUE am_sqlite3_memory_used(VALUE self)
{
    return SQLINT64_2NUM(sqlite3_memory_used());
}

/*
 * Return the maximum value of Amalgalite::SQLite3.memory_used since the last
 * time the highwater mark was reset.
 *
 * :call-seq:
 *    Amalgalite::SQLite3.memory_highwater_mark -> Numeric
 *
 */
VALUE am_sqlite3_memory_highwater(VALUE self)
{
    return SQLINT64_2NUM(sqlite3_memory_highwater(0));
}

/*
 * Reset the memory highwater mark.  The highwater mark becomes the current
 * value of sqlite3_memory_used.
 *
 * :call-seq:
 *    Amalgalite::SQLite3.memory_highwater_mark_reset! 
 *
 */
VALUE am_sqlite3_memory_highwater_reset(VALUE self)
{
    return SQLINT64_2NUM(sqlite3_memory_highwater(1));
}

/*
 * Generate N bytes of random data.
 *
 * :call-seq:
 *    Amalgalite::SQLite3.randomness( 4 ) -> String of length 4
 */
VALUE am_sqlite3_randomness(VALUE self, VALUE num_bytes)
{
    int n     = NUM2INT(num_bytes);
    char *buf = ALLOCA_N(char, n);

    sqlite3_randomness( n, buf );
    return rb_str_new( buf, n );
}


/***********************************************************************
 * Extension initialization
 ***********************************************************************/
void Init_amalgalite3()
{
    /*
     * module Amalgalite
     */
    mA = rb_define_module("Amalgalite");
    
    /*
     * Amalgalite::Sqlite3 methods/constantsn
     */
    mAS  = rb_define_module_under(mA, "SQLite3");
    rb_define_module_function(mAS, "threadsafe?", am_sqlite3_threadsafe, 0);
    rb_define_module_function(mAS, "complete?", am_sqlite3_complete, -2);
    rb_define_module_function(mAS, "memory_used", am_sqlite3_memory_used,0);
    rb_define_module_function(mAS, "memory_highwater_mark", am_sqlite3_memory_highwater,0);
    rb_define_module_function(mAS, "memory_highwater_mark_reset!", am_sqlite3_memory_highwater_reset,0);
    rb_define_module_function(mAS, "randomness", am_sqlite3_randomness,1);

    /* class Amalgalite::Sqlite3::Error 
     */
    eAS_Error = rb_define_class_under(mAS, "Error", rb_eStandardError);

    /* module Amalgalite::Sqlite3::Version and methods
     */
    mASV = rb_define_module_under(mAS, "Version");
    rb_define_module_function(mASV, "to_s", am_sqlite3_libversion, 0);
    rb_define_module_function(mASV, "to_i", am_sqlite3_libversion_number, 0);

    /* module Amalgalite::Sqlite3::Constants
     */
    am_define_constants_under(mAS);

    /*
     * class Database
     */
    cAS_Database = rb_define_class_under(mAS, "Database", rb_cObject); 
    rb_define_alloc_func(cAS_Database, am_sqlite3_database_alloc); /* in amalgalite3_database.c */
    rb_define_singleton_method(cAS_Database, "open", am_sqlite3_database_open, -1); /* in amalgalite3_database.c */
    rb_define_singleton_method(cAS_Database, "open16", am_sqlite3_database_open16, 1); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "prepare", am_sqlite3_database_prepare, 1); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "close", am_sqlite3_database_close, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "last_insert_rowid", am_sqlite3_database_last_insert_rowid, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "autocommit?", am_sqlite3_database_is_autocommit, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "register_trace_tap", am_sqlite3_database_register_trace_tap, 1); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "register_profile_tap", am_sqlite3_database_register_profile_tap, 1); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "table_column_metadata", am_sqlite3_database_table_column_metadata, 3); /* in amalgalite3_database.c */

    /*
     * class Statement
     */
    cAS_Statement = rb_define_class_under(mAS, "Statement", rb_cObject); 
    rb_define_alloc_func(cAS_Statement, am_sqlite3_statement_alloc); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "sql", am_sqlite3_statement_sql, 0); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "close", am_sqlite3_statement_close, 0); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "step", am_sqlite3_statement_step, 0); /* in amalgalite3_statement.c */

    rb_define_method(cAS_Statement, "column_count", am_sqlite3_statement_column_count, 0); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_name", am_sqlite3_statement_column_name, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_declared_type", am_sqlite3_statement_column_decltype, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_type", am_sqlite3_statement_column_type, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_text", am_sqlite3_statement_column_text, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_int", am_sqlite3_statement_column_int, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_int64", am_sqlite3_statement_column_int64, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_double", am_sqlite3_statement_column_double, 1); /* in amalgalite3_statement.c */

    rb_define_method(cAS_Statement, "column_database_name", am_sqlite3_statement_column_database_name, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_table_name", am_sqlite3_statement_column_table_name, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "column_origin_name", am_sqlite3_statement_column_origin_name, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "reset!", am_sqlite3_statement_reset, 0); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "clear_bindings!", am_sqlite3_statement_clear_bindings, 0); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "parameter_count", am_sqlite3_statement_bind_parameter_count, 0); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "parameter_index", am_sqlite3_statement_bind_parameter_index, 1); /* in amalgalite3_statement.c */
    rb_define_method(cAS_Statement, "remaining_sql", am_sqlite3_statement_remaining_sql, 0); /* in amalgalite_statement.c */
    rb_define_method(cAS_Statement, "bind_text", am_sqlite3_statement_bind_text, 2); /* in amalgalite_statement.c */
    rb_define_method(cAS_Statement, "bind_int", am_sqlite3_statement_bind_int, 2); /* in amalgalite_statement.c */
    rb_define_method(cAS_Statement, "bind_int64", am_sqlite3_statement_bind_int64, 2); /* in amalgalite_statement.c */
    rb_define_method(cAS_Statement, "bind_double", am_sqlite3_statement_bind_double, 2); /* in amalgalite_statement.c */
    rb_define_method(cAS_Statement, "bind_null", am_sqlite3_statement_bind_null, 1); /* in amalgalite_statement.c */

}


