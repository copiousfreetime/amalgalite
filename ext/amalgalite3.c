/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

#include "amalgalite3.h"

/* Module and Classes */
VALUE mA;              /* module Amalgalite                     */
VALUE mAS;             /* module Amalgalite::SQLite3            */
VALUE mASV;            /* module Amalgalite::SQLite3::Version   */
VALUE eAS_Error;       /* class  Amalgalite::SQLite3::Error     */

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
 *    Amalgalite::SQLite3.status_for( status_obj ) -> Hash
 *
 * return a hash holindg a 'current' and 'highwater' value for the input status
 * code.  this method is normally called by a Status object internally and is
 * not normally invoked by application code.
 *
 */
VALUE am_sqlite3_status_for( VALUE self, VALUE status )
{
    int status_op = FIX2INT( rb_funcall( status, rb_intern( "code" ), 0 ) );
    int current   = 0;
    int highwater = 0;
    int rc;
    VALUE result = rb_hash_new();

    rc = sqlite3_status( status_op, &current, &highwater, 0 );
    if ( SQLITE_OK != rc ) {
        VALUE n    = rb_funcall( status, rb_intern( "name" ), 0 );
        char* name = StringValuePtr( n );
        rb_raise(eAS_Error, "Failure to retrieve status for %s : [SQLITE_ERROR %d] \n", name, rc);
    }

    rb_hash_aset( result, rb_str_new2( "current" ), INT2NUM( current ) );
    rb_hash_aset( result, rb_str_new2( "highwater" ), INT2NUM( highwater ) );

    return result;
}

/*
 * call-seq:
 *    Amalgalite::SQLite3.status_reset_for( status_obj ) -> true
 *
 * reset the highwater value for the given status code.  The codes are in the
 * Status classes and this method is normaly invoked by the Status#reset!
 * method.  It is not normally called from application code.
 *
 */
VALUE am_sqlite3_status_reset_for( VALUE self, VALUE status )
{
    int current   = 0;
    int highwater = 0;
    int rc;
    int status_op = FIX2INT( rb_funcall( status, rb_intern( "code" ), 0 ) );

    rc = sqlite3_status( status_op, &current, &highwater, 1 );
    if ( SQLITE_OK != rc ) {
        VALUE n    = rb_funcall( status, rb_intern( "name" ), 0 );
        char* name = StringValuePtr( n );
        rb_raise(eAS_Error, "Failure to reset status on %s : [SQLITE_ERROR %d] \n", name, rc);
    }

    return Qtrue;
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

/**
 * The Amalgalite ruby extension
 */

void Init_amalgalite3()
{
    /*
     * top level module encapsulating the entire Amalgalite library
     */
    mA   = rb_define_module("Amalgalite");

    /*
     * module encapsulating the SQLite C extension
     */
    mAS  = rb_define_module_under(mA, "SQLite3");
    rb_define_module_function(mAS, "threadsafe?", am_sqlite3_threadsafe, 0);
    rb_define_module_function(mAS, "complete?", am_sqlite3_complete, -2);
    rb_define_module_function(mAS, "randomness", am_sqlite3_randomness,1);
    rb_define_module_function(mAS, "status_for", am_sqlite3_status_for, 1);
    rb_define_module_function(mAS, "status_reset_for", am_sqlite3_status_reset_for,1);


    /* 
     * Base class of all SQLite3 errors
     */
    eAS_Error = rb_define_class_under(mAS, "Error", rb_eStandardError);

    /**
     * Encapsulation of the SQLite C library version
     */
    mASV = rb_define_module_under(mAS, "Version");
    rb_define_module_function(mASV, "to_s", am_sqlite3_libversion, 0); /* in amalgalite3.c */
    rb_define_module_function(mASV, "to_i", am_sqlite3_libversion_number, 0); /* in amalgalite3.c */

    /*
     * Initialize the rest of the module
     */
    Init_amalgalite3_constants( );
    Init_amalgalite3_database( );
    Init_amalgalite3_statement( );
    Init_amalgalite3_blob( );
    Init_amalgalite3_requires_bootstrap( );

 }


