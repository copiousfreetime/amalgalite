/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

#include "amalgalite3.h"
#include <stdio.h>
extern VALUE mA;
VALUE cAR;
VALUE cARB;
VALUE eARB_Error;

/* 
 * cleanup the datatbase and statment values if they are currently open and then
 * raise the message.  It converts the error message to a String so that the C
 * string can be free'd and then raise with a ruby object in the hopes that
 * there is no memory leak from the C allocation.
 */
void am_bootstrap_cleanup_and_raise( char* msg, sqlite3* db, sqlite3_stmt* stmt, VALUE free_msg )
{

    if ( NULL != stmt ) { sqlite3_finalize( stmt ); stmt = NULL; }
    if ( NULL != db   ) { sqlite3_close( db ); }
    
    if (free_msg == Qtrue)
        free( msg );
    rb_raise(eARB_Error, msg );
}


/**
 * call-seq:
 *   Amalgalite::Requires::Bootstrap.lift( 'dbfile' => "lib.db", 'table_name' => "bootload", 'rowid_column' => "id", 'filename_column' => "filename",  'content_column' => "contents" )
 *
 * *WARNING* *WARNING* *WARNING* *WARNING* *WARNING* *WARNING* *WARNING*
 *
 * This is a boostrap mechanism to eval all the code in a particular column in a
 * specially formatted table in an sqlite database.  It should only be used for
 * a specific purpose, mainly loading the Amalgalite ruby code directly from an
 * sqlite table.  
 *
 * Amalgalite::Requires adds in the ability to _require_ code that is in an
 * sqlite database.  Since Amalgalite::Requires is itself ruby code, if
 * Amalgalite::Requires was in an sqlite database, it could not _require_
 * itself.  Therefore this method is made available.  It is a pure C extension
 * method that directly calls the sqlite3 C functions directly and uses the ruby
 * C api to eval the data in the table.
 *
 * This method attaches to an sqlite3 database (filename) and then does:
 *
 *     SELECT filename_column_name, content_column_name 
 *       FROM table_name
 *   ORDER BY rowid_column_name
 *
 * For each row returned it does an _eval_ on the code in the
 * *content_column_name* and then updates _$LOADED_FEATURES_ directly with the value from
 * *filename_column_name*.
 *
 * The database to be opened by _lift_ *must* be an sqlite3 UTF-8 database.
 *
 */
VALUE am_bootstrap_lift( VALUE self, VALUE args )
{
    sqlite3*        db = NULL;
    sqlite3_stmt* stmt = NULL;
    int             rc;
    int  last_row_good; 
    char raise_msg[BUFSIZ];

    VALUE     am_db_c     = rb_const_get( cARB, rb_intern("DEFAULT_DB") );
    VALUE    am_tbl_c     = rb_const_get( cARB, rb_intern("DEFAULT_BOOTSTRAP_TABLE") );
    VALUE     am_pk_c     = rb_const_get( cARB, rb_intern("DEFAULT_ROWID_COLUMN") );
    VALUE  am_fname_c     = rb_const_get( cARB, rb_intern("DEFAULT_FILENAME_COLUMN") );
    VALUE am_content_c    = rb_const_get( cARB, rb_intern("DEFAULT_CONTENTS_COLUMN") );

    char*     dbfile = NULL;
    char*    tbl_name = NULL;
    char*      pk_col = NULL;
    char*   fname_col = NULL;
    char* content_col = NULL;

    char             sql[BUFSIZ];
    const char* sql_tail = NULL;
    int        sql_bytes = 0;
    
    const unsigned char* result_text = NULL;
    int                result_length = 0;

    VALUE     require_name = Qnil;  /* ruby string of the file name for use in eval */
    VALUE   eval_this_code = Qnil;  /* ruby string of the code to eval from the db  */
    VALUE toplevel_binding = rb_const_get( rb_cObject, rb_intern("TOPLEVEL_BINDING") ) ;
    VALUE              tmp = Qnil;

    ID             eval_id = rb_intern("eval");


    if (   Qnil == args  ) {
        args = rb_hash_new();
    } else {
        args = rb_ary_shift( args );
    }

    Check_Type( args, T_HASH );
    
    /* get the arguments */
    dbfile      = ( Qnil == (tmp = rb_hash_aref( args, rb_str_new2( "dbfile"          ) ) ) ) ? StringValuePtr( am_db_c )      : StringValuePtr( tmp );
    tbl_name    = ( Qnil == (tmp = rb_hash_aref( args, rb_str_new2( "table_name"      ) ) ) ) ? StringValuePtr( am_tbl_c )     : StringValuePtr( tmp );
    pk_col      = ( Qnil == (tmp = rb_hash_aref( args, rb_str_new2( "rowid_column"    ) ) ) ) ? StringValuePtr( am_pk_c )      : StringValuePtr( tmp );
    fname_col   = ( Qnil == (tmp = rb_hash_aref( args, rb_str_new2( "filename_column" ) ) ) ) ? StringValuePtr( am_fname_c )   : StringValuePtr( tmp );
    content_col = ( Qnil == (tmp = rb_hash_aref( args, rb_str_new2( "contents_column" ) ) ) ) ? StringValuePtr( am_content_c ) : StringValuePtr( tmp );


    /* open the database */
    rc = sqlite3_open_v2( dbfile , &db, SQLITE_OPEN_READONLY, NULL);
    if ( SQLITE_OK != rc ) {
        memset( raise_msg, 0, BUFSIZ );
        snprintf(raise_msg, BUFSIZ, "Failure to open database %s for bootload: [SQLITE_ERROR %d] : %s", dbfile, rc, sqlite3_errmsg( db ) );
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt, Qfalse );
    }

    /* prepare the db query */
    memset( sql, 0, BUFSIZ );
    sql_bytes = snprintf( sql, BUFSIZ, "SELECT %s, %s FROM %s ORDER BY %s", fname_col, content_col, tbl_name, pk_col );
    rc = sqlite3_prepare_v2( db, sql, sql_bytes, &stmt, &sql_tail ) ;
    if ( SQLITE_OK != rc) {
        memset( raise_msg, 0, BUFSIZ );
        snprintf( raise_msg, BUFSIZ,
                  "Failure to prepare bootload select statement table = '%s', rowid col = '%s', filename col ='%s', contents col = '%s' : [SQLITE_ERROR %d] %s\n",
                  tbl_name, pk_col, fname_col, content_col, rc, sqlite3_errmsg( db ));
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt, Qfalse );
    }

    /* loop over the resulting rows, eval'ing and loading $LOADED_FEATURES */
    last_row_good = -1;
    while ( SQLITE_ROW == ( rc = sqlite3_step( stmt ) ) ) {
        /* file name */
        result_text   = sqlite3_column_text( stmt, 0 );
        result_length = sqlite3_column_bytes( stmt, 0 );
        require_name  = rb_str_new( (const char*)result_text, result_length );

        /* ruby code */
        result_text    = sqlite3_column_text( stmt, 1 );
        result_length  = sqlite3_column_bytes( stmt, 1 );
        eval_this_code = rb_str_new( (const char*)result_text, result_length );

        /* Kernel.eval( code, TOPLEVEL_BINDING, filename, 1 ) */ 
        rb_funcall(rb_mKernel, eval_id, 4, eval_this_code, toplevel_binding, require_name, INT2FIX(1) );

        /* TODO: for ruby 1.9 -- put in ? sqlite3://path/to/database?tablename=tbl_name#require_name */
        /* update $LOADED_FEATURES */
        rb_ary_push( rb_gv_get( "$LOADED_FEATURES" ), require_name );
    }

    /* if there was some sqlite error in the processing of the rows */
    if ( SQLITE_DONE != rc ) {
        memset( raise_msg, 0, BUFSIZ );
        snprintf( raise_msg, BUFSIZ, "Failure in bootloading, last successfully loaded rowid was %d : [SQLITE_ERROR %d] %s\n", 
                  last_row_good, rc, sqlite3_errmsg( db ) );
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt, Qfalse );
    }

    /* finalize the statement */    
    rc = sqlite3_finalize( stmt );
    if ( SQLITE_OK != rc ) {
        memset( raise_msg, 0, BUFSIZ );
        snprintf( raise_msg, BUFSIZ, "Failure to finalize bootload statement : [SQLITE_ERROR %d] %s\n", rc, sqlite3_errmsg( db ) );
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt, Qfalse );
    }

    stmt = NULL;

    /* close the database */
    rc = sqlite3_close( db );
    if ( SQLITE_OK != rc ) {
        memset( raise_msg, 0, BUFSIZ );
        snprintf( raise_msg, BUFSIZ, "Failure to close database : [SQLITE_ERROR %d] : %s\n", rc, sqlite3_errmsg( db )),
        am_bootstrap_cleanup_and_raise( raise_msg, db,stmt, Qfalse );
    }

    return Qnil;
}

/**
 * Bootstrapping module to help _require_ when Amalgalite::Requires is not
 * availble in files.
 */
void Init_amalgalite3_requires_bootstrap()
{

    mA   = rb_define_module("Amalgalite");
    cAR  = rb_define_class_under(mA, "Requires", rb_cObject);
    cARB = rb_define_class_under(cAR, "Bootstrap", rb_cObject);

    eARB_Error = rb_define_class_under(cARB, "Error", rb_eStandardError);

    rb_define_module_function(cARB, "lift", am_bootstrap_lift, -2); 

    /* constants for default db, table, column, rowid, contents */ 
    rb_define_const(cARB,                "DEFAULT_DB", rb_str_new2( "lib.db" ));
    rb_define_const(cARB,             "DEFAULT_TABLE", rb_str_new2( "rubylibs" ));
    rb_define_const(cARB,   "DEFAULT_BOOTSTRAP_TABLE", rb_str_new2( "bootstrap" ));
    rb_define_const(cARB,      "DEFAULT_ROWID_COLUMN", rb_str_new2( "id" ));
    rb_define_const(cARB,   "DEFAULT_FILENAME_COLUMN", rb_str_new2( "filename" ));
    rb_define_const(cARB,   "DEFAULT_CONTENTS_COLUMN", rb_str_new2( "contents" ));
    rb_define_const(cARB, "DEFAULT_COMPRESSED_COLUMN", rb_str_new2( "compressed" ));

    return;
}

