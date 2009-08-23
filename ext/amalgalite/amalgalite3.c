/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
:*/ 

#include "amalgalite3.h"

/* Module and Classes */
VALUE mA;              /* module Amalgalite                     */
VALUE mAS;             /* module Amalgalite::SQLite3            */
VALUE mASV;            /* module Amalgalite::SQLite3::Version   */
VALUE eAS_Error;       /* class  Amalgalite::SQLite3::Error     */
VALUE cAS_Stat;        /* class  Amalgalite::SQLite3::Stat      */

/*----------------------------------------------------------------------
 * module methods for Amalgalite::SQLite3
 *---------------------------------------------------------------------*/

/*
 * call-seq:
 *    Amalgalite::SQLite3.threadsafe? -> true or false
 *
 * Has the SQLite3 extension been compiled "threadsafe".  If threadsafe? is
 * true then the internal SQLite mutexes are enabled and SQLite is threadsafe.
 * That is threadsafe within the context of 'C' threads.
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
 * call-seq:
 *  Amalgalite::SQLite.temp_directory -> String or nil
 *
 * Return the directory name that all that all the temporary files created by
 * SQLite creates will be placed.  If _nil_ is returned, then SQLite will search
 * for an appropriate directory.
 */
VALUE am_sqlite3_get_temp_directory( VALUE self )
{
    if (NULL == sqlite3_temp_directory) {
        return Qnil;
    } else {
        return rb_str_new2( sqlite3_temp_directory );
    }
}

/*
 * call-seq:
 *  Amalgalite::SQLite.temp_directory = "/tmp/location"
 *
 * Set the temporary directory used by sqlite to store temporary directories.
 * It is not safe to set this value after a Database has been opened.
 *
 */
VALUE am_sqlite3_set_temp_directory( VALUE self, VALUE new_dir )
{
    char *p   = NULL ;

    if ( NULL != sqlite3_temp_directory ) {
        free( sqlite3_temp_directory );
    }

    if ( Qnil != new_dir ) {
        VALUE str = StringValue( new_dir );

        p = calloc( RSTRING_LEN(str) + 1, sizeof(char) );
        strncpy( p, RSTRING_PTR(str), RSTRING_LEN(str) );
    }

    sqlite3_temp_directory = p;

    return Qnil;
}

VALUE amalgalite_format_string( char* pattern, VALUE string )
{
    VALUE to_s= rb_funcall( string, rb_intern("to_s"), 0 );
    VALUE str = StringValue( to_s );
    char *p   = sqlite3_mprintf(pattern, RSTRING_PTR(str));
    VALUE rv  = Qnil;
    if ( NULL != p ) {
        rv  = rb_str_new2( p );
        sqlite3_free( p );
    } else {
        rb_raise( rb_eNoMemError, "Unable to quote string" );
    } 

    return rv;
}
/*
 * call-seq:
 *  Amalgalite::SQLite.escape( string ) => escaped_string
 *
 * Takes the input string and escapes each ' (single quote) character by
 * doubling it.
 */
VALUE am_sqlite3_escape( VALUE self, VALUE string )
{ 
    return ( Qnil == string ) ? Qnil : amalgalite_format_string( "%q", string );
}

/*
 * call-seq:
 *  Amalgalite::SQLite.quote( string ) => quoted-escaped string
 *
 * Takes the input string and surrounds it with single quotes, it also escapes
 * each embedded single quote with double quotes.
 */
VALUE am_sqlite3_quote( VALUE self, VALUE string )
{
    return ( Qnil == string ) ? Qnil : amalgalite_format_string( "%Q", string );
}

/*
 * call-seq:
 *    Amalgalite::SQLite3.complete?( ... , opts = { :utf16 => false }) -> True, False
 *
 * Is the text passed in as a parameter a complete SQL statement?  Or is
 * additional input required before sending the SQL to the extension.  If the
 * extra 'opts' parameter is used, you can send in a UTF-16 encoded string as
 * the SQL.
 *
 * A complete statement must end with a semicolon.
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
 * call-seq:
 *    Amalgalite::SQLite3::Stat.update!( reset = false ) -> nil
 *
 * Populates the _@current_ and _@higwater_ instance variables of self
 * object with the values from the sqlite3_status call.  If reset it true then
 * the highwater mark for the stat is reset
 *
 */
VALUE am_sqlite3_stat_update_bang( int argc, VALUE *argv, VALUE self )
{
    int status_op  = -1;
    int current    = -1;
    int highwater  = -1;
    VALUE reset    = Qfalse;
    int reset_flag = 0;
    int rc;

    status_op  = FIX2INT( rb_iv_get( self, "@code" ) );
    if ( argc > 0 ) {
        reset = argv[0];
        reset_flag = ( Qtrue == reset ) ? 1 : 0 ;
    }

    rc = sqlite3_status( status_op, &current, &highwater, reset_flag );

    if ( SQLITE_OK != rc ) {
        VALUE n    = rb_iv_get( self,  "@name" ) ;
        char* name = StringValuePtr( n );
        rb_raise(eAS_Error, "Failure to retrieve status for %s : [SQLITE_ERROR %d] \n", name, rc);
    }

    rb_iv_set( self, "@current", INT2NUM( current ) );
    rb_iv_set( self, "@highwater", INT2NUM( highwater) );

    return Qnil;
}

/*
 * call-seq:
 *    Amalgalite::SQLite3.randomness( N ) -> String of length N
 *
 * Generate N bytes of random data.
 *
 */
VALUE am_sqlite3_randomness(VALUE self, VALUE num_bytes)
{
    int n     = NUM2INT(num_bytes);
    char *buf = ALLOCA_N(char, n);

    sqlite3_randomness( n, buf );
    return rb_str_new( buf, n );
}

/*----------------------------------------------------------------------
 * module methods for Amalgalite::SQLite3::Version
 *---------------------------------------------------------------------*/

/*
 * call-seq:
 *    Amalgalite::SQLite3::Version.to_s -> String
 *
 * Return the SQLite C library version number as a string
 *
 */
VALUE am_sqlite3_libversion(VALUE self)
{
    return rb_str_new2(sqlite3_libversion());
}

/*
 * call-seq:
 *    Amalgalite::SQLite3.Version.to_i -> Fixnum
 *
 * Return the SQLite C library version number as an integer
 *
 */
VALUE am_sqlite3_libversion_number(VALUE self)
{
    return INT2FIX(sqlite3_libversion_number());
}

/*
 * call-seq:
 *   Return the sqlite3_version[] constant as a ruby string
 *
 */
VALUE am_sqlite3_version(VALUE self)
{
    return rb_str_new2( sqlite3_version );
}

/**
 * Document-class: Amalgalite::SQLite3
 *
 * The SQLite ruby extension inside Amalgalite.
 *
 */

void Init_amalgalite3()
{
    /*
     * top level module encapsulating the entire Amalgalite library
     */
    mA   = rb_define_module("Amalgalite");

    mAS  = rb_define_module_under(mA, "SQLite3");
    rb_define_module_function(mAS, "threadsafe?", am_sqlite3_threadsafe, 0);
    rb_define_module_function(mAS, "complete?", am_sqlite3_complete, -2);
    rb_define_module_function(mAS, "randomness", am_sqlite3_randomness,1);
    rb_define_module_function(mAS, "temp_directory", am_sqlite3_get_temp_directory, 0);
    rb_define_module_function(mAS, "temp_directory=", am_sqlite3_set_temp_directory, 1);

    rb_define_module_function(mAS, "escape", am_sqlite3_escape, 1);
    rb_define_module_function(mAS, "quote", am_sqlite3_quote, 1);

    /*
     * class encapsulating a single Stat
     */
    cAS_Stat = rb_define_class_under(mAS, "Stat", rb_cObject);
    rb_define_method(cAS_Stat, "update!", am_sqlite3_stat_update_bang, -1);

    /* 
     * Base class of all SQLite3 errors
     */
    eAS_Error = rb_define_class_under(mAS, "Error", rb_eStandardError); /* in amalgalite.c */

    /**
     * Encapsulation of the SQLite C library version
     */
    mASV = rb_define_module_under(mAS, "Version");
    rb_define_module_function(mASV, "to_s", am_sqlite3_libversion, 0); /* in amalgalite3.c */
    rb_define_module_function(mASV, "to_i", am_sqlite3_libversion_number, 0); /* in amalgalite3.c */
    rb_define_module_function(mASV, "version_string", am_sqlite3_version, 0 ); /* in amalgalite3.c */

    /*
     * Initialize the rest of the module
     */
    Init_amalgalite3_constants( );
    Init_amalgalite3_database( );
    Init_amalgalite3_statement( );
    Init_amalgalite3_blob( );
    Init_amalgalite3_requires_bootstrap( );

 }


