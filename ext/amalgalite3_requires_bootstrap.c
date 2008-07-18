/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

#ifdef AMALGALITE_ENABLE_REQUIRES_BOOTSTRAP

#include "amalgalite3.h"
extern VALUE mA;
static VALUE mAR;
static VALUE mARB;
static VALUE eARB_Error;

/* 
 * cleanup the datatbase and statment values if they are currently open and then
 * raise the message.  It converts the error message to a String so that the C
 * string can be free'd and then raise with a ruby object in the hopes that
 * there is no memory leak from the C allocation.
 */
void am_bootstrap_cleanup_and_raise( char* msg, sqlite3* db, sqlite3_stmt* stmt )
{
    VALUE msg_obj = rb_str_new2( msg );

    if ( NULL != stmt ) { sqlite3_finalize( stmt ); }
    if ( NULL != db   ) { sqlite3_close( db ); }

    free( msg );
    rb_raise(eARB_Error, msg );
}


/**
 * call-seq:
 *   Amalgalite::Requires::Bootstrap.lift( filename = "lib.db", table_name = "bootload", rowid_column_name = "id", filename_column_name = "filename",  content_column_name = "contents" )
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
 * *content_column_name* and then updates _$"_ directly with the value from
 * *filename_column_name*.
 *
 * Some caveats
 *
 * 1. This method is not made available by default.  It must specifically be
 *    enabled when the extension is built.  To enable it build the extension
 *    with:
 *
 *    <tt>ruby extconf.rb --enable-load-table-contents</tt>
 *
 * 2. The database to be opened *must* be an sqlite UTF-8 database.
 *
 */
VALUE am_bootstrap_lift( VALUE self, VALUE db_file_name, VALUE table_name,
                         VALUE rowid_col_name, VALUE filename_col_name, 
                         VALUE content_col_name)
{
    sqlite3*        db = NULL;
    sqlite3_stmt* stmt = NULL;
    int             rc;
    int  last_row_good; 
    char*    raise_msg = NULL;

    VALUE     am_db_c  = rb_const_get( mARB, rb_intern("DEFAULT_DB") );
    VALUE    am_tbl_c  = rb_const_get( mARB, rb_intern("DEFAULT_TABLE") );
    VALUE     am_pk_c  = rb_const_get( mARB, rb_intern("DEFAULT_ROWID_COLUMN") );
    VALUE  am_fname_c  = rb_const_get( mARB, rb_intern("DEFAULT_FILENAME_COLUMN") );
    VALUE am_content_c = rb_const_get( mARB, rb_intern("DEFAULT_CONTENTS_COLUMN") );

    char*     db_name = ( Qnil == db_file_name      ) ? StringValuePtr( am_db_c )      : StringValuePtr( db_file_name      );
    char*    tbl_name = ( Qnil == table_name        ) ? StringValuePtr( am_tbl_c )     : StringValuePtr( table_name        );
    char*      pk_col = ( Qnil == rowid_col_name    ) ? StringValuePtr( am_pk_c )      : StringValuePtr( rowid_col_name    );
    char*   fname_col = ( Qnil == filename_col_name ) ? StringValuePtr( am_fname_c )   : StringValuePtr( filename_col_name );
    char* content_col = ( Qnil == content_col_name  ) ? StringValuePtr( am_content_c ) : StringValuePtr( content_col_name  );

    char*            sql = NULL;
    const char* sql_tail = NULL;
    int        sql_bytes = 0;
    
    const unsigned char* result_text = NULL;
    int                result_length = 0;

    VALUE     require_name = Qnil;  /* ruby string of the file name for use in eval */
    VALUE   eval_this_code = Qnil;  /* ruby string of the code to eval from the db  */
    VALUE toplevel_binding = rb_const_get( rb_cObject, rb_intern("TOPLEVEL_BINDING") ) ;
    VALUE    sqlite_errmsg = Qnil;

    ID             eval_id = rb_intern("eval");

    /* open the database */
    rc = sqlite3_open_v2( db_name, &db, SQLITE_OPEN_READONLY, NULL);
    if ( SQLITE_OK != rc ) {
        asprintf(&raise_msg,"Failure to open database %s for bootload: [SQLITE_ERROR %d] : %s", db_name, rc, sqlite3_errmsg( db ) );
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt );
    }

    /* prepare the db query */
    sql_bytes = asprintf( &sql, "SELECT %s, %s FROM %s ORDER BY %s", fname_col, content_col, tbl_name, pk_col );
    rc = sqlite3_prepare_v2( db, sql, sql_bytes, &stmt, &sql_tail ) ;
    free( sql );
    if ( SQLITE_OK != rc) {
        asprintf( &raise_msg, 
                  "Failure to prepare bootload select statement table = '%s', rowid col = '%s', filename col ='%s', contents col = '%s' : [SQLITE_ERROR %d] %s\n",
                  tbl_name, pk_col, fname_col, content_col, rc, sqlite3_errmsg( db ));
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt );
    }

    /* loop over the resulting rows, eval'ing and loading $" */
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
        /* update $" */
        rb_ary_push( rb_gv_get( "$\"" ), require_name );
    }

    /* if there was some sqlite error in the processing of the rows */
    if ( SQLITE_DONE != rc ) {
        asprintf( &raise_msg, "Failure in bootloading, last successfully loaded rowid was %d : [SQLITE_ERROR %d] %s\n", 
                  last_row_good, rc, sqlite3_errmsg( db ) );
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt );
    }

    /* finalize the statement */    
    rc = sqlite3_finalize( stmt );
    if ( SQLITE_OK != rc ) {
        asprintf( &raise_msg, "Failure to finalize bootload statement : [SQLITE_ERROR %d]\n", rc, sqlite3_errmsg( db ) );
        am_bootstrap_cleanup_and_raise( raise_msg, db, stmt );
    }

    stmt = NULL;

    /* close the database */
    rc = sqlite3_close( db );
    if ( SQLITE_OK != rc ) {
        asprintf( &raise_msg, "Failure to close database : [SQLITE_ERROR %d] : %s\n", rc, sqlite3_errmsg( db )),
        am_bootstrap_cleanup_and_raise( raise_msg, db,stmt );
    }

    return Qnil;
}

void Init_amalgalite3_requires_bootstrap()
{

    mA   = rb_define_module("Amalgalite");
    mAR  = rb_define_module_under(mA, "Requires");
    mARB = rb_define_module_under(mAR, "Bootstrap");

    eARB_Error = rb_define_class_under(mARB, "Error", rb_eStandardError);

    rb_define_module_function(mARB, "lift", am_bootstrap_lift, 5); 

    /* constants for default db, table, column, rowid, contents */ 
    rb_define_const(mARB,              "DEFAULT_DB", rb_str_new2( "lib.db" ));
    rb_define_const(mARB,           "DEFAULT_TABLE", rb_str_new2( "bootstrap" ));
    rb_define_const(mARB,    "DEFAULT_ROWID_COLUMN", rb_str_new2( "id" ));
    rb_define_const(mARB, "DEFAULT_FILENAME_COLUMN", rb_str_new2( "filename" ));
    rb_define_const(mARB, "DEFAULT_CONTENTS_COLUMN", rb_str_new2( "contents" ));

    return;
}

#endif
