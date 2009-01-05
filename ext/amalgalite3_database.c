#include "amalgalite3.h"
/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4
 */

VALUE cAS_Database;       /* class  Amalgliate::SQLite3::Database        */
VALUE cAS_Database_Stat;  /* class  Amalgliate::SQLite3::Database::Stat  */

/**
 * Document-method: open
 *
 * call-seq:
 *    Amalagliate::SQLite3::Database.open( filename, flags = READWRITE | CREATE ) -> Database
 *
 * Create a new SQLite2 database with a UTF-8 encoding.
 *
 */
VALUE am_sqlite3_database_open(int argc, VALUE *argv, VALUE class)
{
    VALUE  self = am_sqlite3_database_alloc(class);
    VALUE  rFlags;
    VALUE  rFilename;
    int     flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
    char*   filename;
    int     rc;
    am_sqlite3* am_db;

    /* at least a filename argument is required */
    rb_scan_args( argc, argv, "11", &rFilename, &rFlags );

    /* convert flags to the sqlite version */
    flags  = ( Qnil == rFlags ) ? flags : FIX2INT(rFlags);
    filename = StringValuePtr(rFilename);

    /* extract the sqlite3 wrapper struct */
    Data_Get_Struct(self, am_sqlite3, am_db);

    /* open the sqlite3 database */
    rc = sqlite3_open_v2( filename, &(am_db->db), flags, 0);
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Failure to open database %s : [SQLITE_ERROR %d] : %s\n",
                filename, rc, sqlite3_errmsg(am_db->db));
    }

    /* by default turn on the extended result codes */
    rc = sqlite3_extended_result_codes( am_db->db, 1);
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Failure to set extended result codes %s : [SQLITE_ERROR %d] : %s\n",
                filename, rc, sqlite3_errmsg(am_db->db));
    }

    return self;
}

/**
 * call-seq:
 *    Amalgalite::SQLite3::Database.open16( filename ) -> SQLite3::Database
 *
 * Create a new SQLite3 database with a UTF-16 encoding
 *
 */
VALUE am_sqlite3_database_open16(VALUE class, VALUE rFilename)
{
    VALUE       self = am_sqlite3_database_alloc(class);
    char*       filename = StringValuePtr(rFilename);
    am_sqlite3* am_db;
    int         rc;

    Data_Get_Struct(self, am_sqlite3, am_db);
    rc = sqlite3_open16( filename, &(am_db->db) );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Failure to open UTF-16 database %s : [SQLITE_ERROR %d] : %s\n",
                filename, rc, sqlite3_errmsg( am_db->db ));
    }

    /* by default turn on the extended result codes */
    rc = sqlite3_extended_result_codes( am_db->db, 1);
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Failure to set extended result codes on UTF-16 database %s : [SQLITE_ERROR %d] : %s\n",
                filename, rc, sqlite3_errmsg16(am_db->db));
    }

    return self;
}

/**
 * call-seq:
 *    database.close
 *
 * Close the database
 */
VALUE am_sqlite3_database_close(VALUE self)
{
    am_sqlite3   *am_db;
    int           rc = 0;

    Data_Get_Struct(self, am_sqlite3, am_db);
    rc = sqlite3_close( am_db->db );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Failure to close database : [SQLITE_ERROR %d] : %s\n",
                rc, sqlite3_errmsg( am_db->db ));
    }

    return self;

}

/**
 * call-seq:
 *    database.last_insert_rowid -> Integer
 *
 * Return the rowid of the last row inserted into the database from this
 * database connection.
 */
VALUE am_sqlite3_database_last_insert_rowid(VALUE self)
{
    am_sqlite3   *am_db;
    sqlite3_int64 last_id;

    Data_Get_Struct(self, am_sqlite3, am_db);
    last_id = sqlite3_last_insert_rowid( am_db->db );

    return SQLINT64_2NUM( last_id );
}

/**
 * call-seq:
 *    database.autocommit? -> true or false
 *
 * return true if the database is in autocommit mode, otherwise return false
 *
 */
VALUE am_sqlite3_database_is_autocommit(VALUE self)
{
    am_sqlite3   *am_db;
    int           rc;

    Data_Get_Struct(self, am_sqlite3, am_db);
    rc = sqlite3_get_autocommit( am_db->db );

    return ( 0 == rc ) ? Qfalse : Qtrue ;
}

/**
 * call-seq:
 *    database.row_changes -> Integer
 *
 * return the number of rows changed with the most recent INSERT, UPDATE or
 * DELETE statement.
 *
 */
VALUE am_sqlite3_database_row_changes(VALUE self)
{
    am_sqlite3   *am_db;
    int           rc;

    Data_Get_Struct(self, am_sqlite3, am_db);
    rc = sqlite3_changes( am_db->db );

    return INT2FIX(rc);
}

/**
 * call-seq:
 *    database.last_error_code -> Integer
 *
 * return the last error code that happened in the database
 *
 */
VALUE am_sqlite3_database_last_error_code(VALUE self)
{
    am_sqlite3   *am_db;
    int           code;

    Data_Get_Struct(self, am_sqlite3, am_db);
    code = sqlite3_errcode( am_db->db );

    return INT2FIX( code );
}

/**
 * call-seq:
 *    database.last_error_message -> String
 *
 * return the last error message that happened in the database
 *
 */
VALUE am_sqlite3_database_last_error_message(VALUE self)
{
    am_sqlite3   *am_db;
    const char   *message;

    Data_Get_Struct(self, am_sqlite3, am_db);
    message = sqlite3_errmsg( am_db->db );

    return rb_str_new2( message );
}

/**
 * call-seq:
 *    database.total_changes -> Integer
 *
 * return the number of rows changed by INSERT, UPDATE or DELETE statements
 * in the database connection since the connection was opened.
 *
 */
VALUE am_sqlite3_database_total_changes(VALUE self)
{
    am_sqlite3   *am_db;
    int           rc;

    Data_Get_Struct(self, am_sqlite3, am_db);
    rc = sqlite3_total_changes( am_db->db );

    return INT2FIX(rc);
}

/*
 * call-seq:
 *    stat.update!(  reset = false ) -> nil
 *
 * Populates the _@current_ and _@higwater_ instance variables of the given
 * Database Stat object with the values from the sqlite3_db_status call.
 * If reset it true then the highwater mark for the stat is reset
 *
 */
VALUE am_sqlite3_database_stat_update_bang( int argc, VALUE *argv, VALUE self )
{
    int current    = -1;
    int highwater  = -1;
    int reset_flag = 0;
    int status_op  = FIX2INT( rb_iv_get( self, "@code" ) );
    int rc;

    am_sqlite3    *am_db;

    VALUE reset    = Qfalse;
    VALUE db       = rb_iv_get( self, "@api_db" );

    Data_Get_Struct(db, am_sqlite3, am_db);

    if ( argc > 0 ) {
        reset = argv[0];
        reset_flag = ( Qtrue == reset ) ? 1 : 0 ;
    }

    rc = sqlite3_db_status( am_db->db, status_op, &current, &highwater, reset_flag );

    if ( SQLITE_OK != rc ) {
        VALUE n    = rb_iv_get( self, "@name");
        char* name = StringValuePtr( n );
        rb_raise(eAS_Error, "Failure to retrieve database status for %s : [SQLITE_ERROR %d] \n", name, rc);
    }

    rb_iv_set( self, "@current", INT2NUM( current ) );
    rb_iv_set( self, "@highwater", INT2NUM( highwater) );

    return Qnil;
}



/**
 * call-seq:
 *    database.prepare( sql ) -> SQLite3::Statement
 *
 * Create a new SQLite3 statement.
 */
VALUE am_sqlite3_database_prepare(VALUE self, VALUE rSQL)
{
    VALUE            sql = StringValue( rSQL );
    VALUE            stmt = am_sqlite3_statement_alloc(cAS_Statement);
    am_sqlite3      *am_db;
    am_sqlite3_stmt *am_stmt;
    const char      *tail;
    int              rc;

    Data_Get_Struct(self, am_sqlite3, am_db);

    Data_Get_Struct(stmt, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_prepare_v2( am_db->db, RSTRING(sql)->ptr, RSTRING(sql)->len,
                            &(am_stmt->stmt), &tail);
    if ( SQLITE_OK != rc) {
        rb_raise(eAS_Error, "Failure to prepare statement %s : [SQLITE_ERROR %d] : %s\n",
                RSTRING(sql)->ptr, rc, sqlite3_errmsg(am_db->db));
        am_sqlite3_statement_free( am_stmt );
    }

    if ( tail != NULL ) {
        am_stmt->remaining_sql = rb_str_new2( tail );
        rb_gc_register_address( &(am_stmt->remaining_sql) );
    } else {
        am_stmt->remaining_sql = Qnil;
    }

    return stmt;
}

/**
 * This function is registered with a sqlite3 database using the sqlite3_trace
 * function.  During the registration process a handle on a VALUE is also
 * registered.
 *
 * When this function is called, it calls the 'trace' method on the tap object,
 * which is the VALUE that was registered during the sqlite3_trace call.
 *
 * This function corresponds to the SQLite xTrace function specification.
 *
 */
void amalgalite_xTrace(void* tap, const char* msg)
{
    VALUE     trace_obj = (VALUE) tap;

    rb_funcall( trace_obj, rb_intern("trace"), 1, rb_str_new2( msg ) );
    return;
}


/**
 * call-seq:
 *   database.register_trace_tap( tap_obj )
 *
 * This registers an object to be called with every trace event in SQLite.
 *
 * This is an experimental api and is subject to change, or removal.
 *
 */
VALUE am_sqlite3_database_register_trace_tap(VALUE self, VALUE tap)
{
    am_sqlite3   *am_db;

    Data_Get_Struct(self, am_sqlite3, am_db);

    /* Qnil, unregister the item and tell the garbage collector we are done with
     * it.
     */
    if ( Qnil == tap ) {

        sqlite3_trace( am_db->db, NULL, NULL );
        rb_gc_unregister_address( &(am_db->trace_obj) );
        am_db->trace_obj = Qnil;

    /* register the item and store the reference to the object in the am_db
     * structure.  We also have to tell the Ruby garbage collector that we
     * point to the Ruby object from C.
     */
    } else {

        am_db->trace_obj = tap;
        rb_gc_register_address( &(am_db->trace_obj) );
        sqlite3_trace( am_db->db, amalgalite_xTrace, (void *)am_db->trace_obj );
    }

    return Qnil;
}


/**
 * the amagliate trace function to be registered with register_trace_tap
 * When it is called, it calls the 'trace' method on the tap object.
 *
 * This function conforms to the sqlite3 xProfile function specification.
 */
void amalgalite_xProfile(void* tap, const char* msg, sqlite3_uint64 time)
{
    VALUE     trace_obj = (VALUE) tap;

    rb_funcall( trace_obj, rb_intern("profile"),
                2, rb_str_new2( msg ), SQLUINT64_2NUM(time) );

    return;
}

/**
 * call-seq:
 *   database.register_profile_tap( tap_obj )
 *
 * This registers an object to be called with every profile event in SQLite.
 *
 * This is an experimental api and is subject to change or removal.
 *
 */
VALUE am_sqlite3_database_register_profile_tap(VALUE self, VALUE tap)
{
    am_sqlite3   *am_db;

    Data_Get_Struct(self, am_sqlite3, am_db);

    /* Qnil, unregister the item and tell the garbage collector we are done with
     * it.
     */

    if ( tap == Qnil ) {
        sqlite3_profile( am_db->db, NULL, NULL );
        rb_gc_unregister_address( &(am_db->profile_obj) );
        am_db->profile_obj = Qnil;

    /* register the item and store the reference to the object in the am_db
     * structure.  We also have to tell the Ruby garbage collector that we
     * point to the Ruby object from C.
     */
    } else {
        am_db->profile_obj = tap;
        rb_gc_register_address( &(am_db->profile_obj) );
        sqlite3_profile( am_db->db, amalgalite_xProfile, (void *)am_db->profile_obj );
    }
    return Qnil;
}

/**
 * invoke a ruby function.  This is here to be used by rb_protect.
 */
VALUE amalgalite_wrap_funcall2( VALUE arg )
{
    am_protected_t *protected = (am_protected_t*) arg;
    return rb_funcall2( protected->instance, protected->method, protected->argc, protected->argv );
}

/**
 * Set the context result on the sqlite3_context based upon the ruby VALUE.
 * This converts the ruby value to the appropriate C-type and makes the
 * appropriate call sqlite3_result_* call
 */
void amalgalite_set_context_result( sqlite3_context* context, VALUE result )
{
    switch( TYPE(result) ) {
        case T_FIXNUM:
        case T_BIGNUM:
            sqlite3_result_int64( context, NUM2SQLINT64(result) );
            break;
        case T_FLOAT:
            sqlite3_result_double( context, NUM2DBL(result) );
            break;
        case T_NIL:
            sqlite3_result_null( context );
            break;
        case T_TRUE:
            sqlite3_result_int64( context, 1);
            break;
        case T_FALSE:
            sqlite3_result_int64( context, 0);
            break;
        case T_STRING:
            sqlite3_result_text( context, RSTRING(result)->ptr, RSTRING(result)->len, NULL);
            break;
        default:
            sqlite3_result_error( context, "Unable to convert ruby object to an SQL function result", -1 );
            sqlite3_result_error_code( context, 42 );
            break;
    }
    return;
}

/** 
 * Convert from a protected sqlite3_value to a ruby object
 */
VALUE sqlite3_value_to_ruby_value( sqlite3_value* s_value )
{
    VALUE         rb_value = Qnil;
    sqlite3_int64 i64;

    switch( sqlite3_value_type( s_value) ) {
        case SQLITE_NULL:
            rb_value = Qnil;
            break;
        case SQLITE_INTEGER:
            i64 = sqlite3_value_int64( s_value);
            rb_value = SQLINT64_2NUM(i64); 
            break;
        case SQLITE_FLOAT:
            rb_value = rb_float_new( sqlite3_value_double( s_value ) );
            break;
        case SQLITE_TEXT:
        case SQLITE_BLOB:
            rb_value = rb_str_new2((const char*) sqlite3_value_text( s_value ) );
            break;
    }
    return rb_value;
}

/**
 * the amalgalite xFunc callback that is used to invoke the ruby function for
 * doing scalar SQL functions.
 *
 * This function conforms to the xFunc function specification for
 * sqlite3_create_function
 */
void amalgalite_xFunc( sqlite3_context* context, int argc, sqlite3_value** argv )
{
    VALUE         *args = ALLOCA_N( VALUE, argc );
    VALUE          result;
    int            state;
    int            i;
    am_protected_t protected;

    /* convert each item in argv to a VALUE object based upon its type via
     * sqlite3_value_type( argv[n] )
     */
    for( i = 0 ; i < argc ; i++) {
        args[i] = sqlite3_value_to_ruby_value( argv[i] );
    }

    /* gather all the data to make the protected call */
    protected.instance = (VALUE) sqlite3_user_data( context );
    protected.method   = rb_intern("call");
    protected.argc     = argc;
    protected.argv     = args;

    result = rb_protect( amalgalite_wrap_funcall2, (VALUE)&protected, &state );
    /* check the results */
    if ( state ) {
        VALUE msg = ERROR_INFO_MESSAGE();
        sqlite3_result_error( context, RSTRING(msg)->ptr, RSTRING(msg)->len );
    } else {
        amalgalite_set_context_result( context, result );
    }

    return; 
}

/**
 * call-seq:
 *   database.define_function( name, proc_like )
 *
 * register the given function to be invoked as an sql function.
 */
VALUE am_sqlite3_database_define_function( VALUE self, VALUE name, VALUE proc_like )
{
    am_sqlite3   *am_db;
    int           rc;
    VALUE         arity = rb_funcall( proc_like, rb_intern( "arity" ), 0 );
    char*         zFunctionName = RSTRING(name)->ptr;
    int           nArg = FIX2INT( arity );

    Data_Get_Struct(self, am_sqlite3, am_db);
    rc = sqlite3_create_function( am_db->db, 
                                  zFunctionName, nArg,
                                  SQLITE_ANY,
                                  (void *)proc_like, amalgalite_xFunc,
                                  NULL, NULL);
    if ( SQLITE_OK != rc ) {
       rb_raise(eAS_Error, "Failure defining SQL function '%s' with arity '%d' : [SQLITE_ERROR %d] : %s\n",
                zFunctionName, nArg, rc, sqlite3_errmsg( am_db->db ));
    }
    rb_gc_register_address( &proc_like );
    return Qnil;
}

/**
 * call-seq:
 *  database.remove_function( name, proc_like )
 *
 * remove the given function from availability in SQL.
 */
VALUE am_sqlite3_database_remove_function( VALUE self, VALUE name, VALUE proc_like )
{
    am_sqlite3    *am_db;
    int            rc;
    VALUE         arity = rb_funcall( proc_like, rb_intern( "arity" ), 0 );
    char*         zFunctionName = RSTRING(name)->ptr;
    int           nArg = FIX2INT( arity );

    Data_Get_Struct(self, am_sqlite3, am_db);
    rc = sqlite3_create_function( am_db->db, 
                                  zFunctionName, nArg,
                                  SQLITE_ANY,
                                  NULL, NULL,
                                  NULL, NULL);
    if ( SQLITE_OK != rc ) {
       rb_raise(eAS_Error, "Failure removing SQL function '%s' with arity '%d' : [SQLITE_ERROR %d] : %s\n",
                zFunctionName, nArg, rc, sqlite3_errmsg( am_db->db ));
    }
    rb_gc_unregister_address( &proc_like );
    return Qnil;
}



/**
 * the amalgalite xStep callback that is used to invoke the ruby method for
 * doing aggregate step oprations as part of an aggregate SQL function.
 *
 * This function conforms to the xStep function specification for
 * sqlite3_create_function.
 */
void amalgalite_xStep( sqlite3_context* context, int argc, sqlite3_value** argv )
{
    /* functor is a klass that  an instance of is created to hold hte context of
     * the aggregation */
    /*VALUE aggregator = (VALUE) sqlite3_aggregate_context( context, sizeof( amalgalite_aggregate_t) );
    VALUE functor = (VALUE) sqlite3_user_data( context );
    */
    return ;
}

/**
 * the amalgalite xFinal callback that is used to invoke the ruby method for
 * doing aggregate final oprations as part of an aggregate SQL function.
 *
 * This function conforms to the xFinal function specification for
 * sqlite3_create_function.
 */
void amalgalite_xFinal( sqlite3_context* context )
{ 
    VALUE functor = (VALUE) sqlite3_user_data( context );

    return ;
}


/**
 * call-seq:
 *    database.table_column_metadata( db_name, table_name, column_name) -> Hash
 *
 * Returns a hash containing the meta information about the column.  The
 * available keys are:
 *
 * declared_data_type::       the declared data type of the column
 * collation_sequence_name::  the name of the collation sequence for the column
 * not_null_constraint::      True if the column has a NOT NULL constraint
 * primary_key::              True if the column is part of a primary key
 * auto_increment::           True if the column is AUTO INCREMENT
 *
 */
VALUE am_sqlite3_database_table_column_metadata(VALUE self, VALUE db_name, VALUE tbl_name, VALUE col_name)
{
    am_sqlite3  *am_db;
    int         rc;

    /* input */
    const char  *zDbName      = StringValuePtr( db_name );
    const char  *zTableName   = StringValuePtr( tbl_name );
    const char  *zColumnName  = StringValuePtr( col_name );

    /* output */
    const char *pzDataType = NULL;
    const char *pzCollSeq  = NULL;
    int         pNotNull, pPrimaryKey, pAutoinc;
    VALUE       rHash      = rb_hash_new();
    VALUE       rStr       = Qnil;

    Data_Get_Struct(self, am_sqlite3, am_db);

    rc = sqlite3_table_column_metadata( am_db->db,
                                        zDbName, zTableName, zColumnName,
                                        &pzDataType, &pzCollSeq,
                                        &pNotNull, &pPrimaryKey, &pAutoinc);
    if ( SQLITE_OK != rc ) {
       rb_raise(eAS_Error, "Failure retrieveing column meta data for table '%s' column '%s' : [SQLITE_ERROR %d] : %s\n",
                zTableName, zColumnName, rc, sqlite3_errmsg( am_db-> db ));

    }

    rStr = ( NULL == pzDataType) ? Qnil : rb_str_new2( pzDataType );
    rb_hash_aset( rHash, rb_str_new2("declared_data_type"), rStr );

    rStr = ( NULL == pzCollSeq) ? Qnil : rb_str_new2( pzCollSeq );
    rb_hash_aset( rHash, rb_str_new2("collation_sequence_name"), rStr );

    rb_hash_aset( rHash, rb_str_new2("not_null_constraint"),     ( pNotNull    ? Qtrue : Qfalse ));
    rb_hash_aset( rHash, rb_str_new2("primary_key"),             ( pPrimaryKey ? Qtrue : Qfalse ));
    rb_hash_aset( rHash, rb_str_new2("auto_increment"),          ( pAutoinc   ? Qtrue : Qfalse ));

    return rHash;
}

/***********************************************************************
 * Ruby life cycle methods
 ***********************************************************************/


/*
 * garbage collector free method for the am_data structure.  Make sure to un
 * registere the trace and profile objects if they are not Qnil
 */
void am_sqlite3_database_free(am_sqlite3* am_db)
{
    if ( Qnil != am_db->trace_obj ) {
        rb_gc_unregister_address( &(am_db->trace_obj) );
        am_db->trace_obj = Qnil;
    }

    if ( Qnil != am_db->profile_obj) {
        rb_gc_unregister_address( &(am_db->profile_obj) );
        am_db->profile_obj = Qnil;
    }

    free(am_db);
    return;
}

/*
 * allocate the am_data structure
 */
VALUE am_sqlite3_database_alloc(VALUE klass)
{
    am_sqlite3*  am_db = ALLOC(am_sqlite3);
    VALUE          obj ;

    am_db->trace_obj   = Qnil;
    am_db->profile_obj = Qnil;

    obj = Data_Wrap_Struct(klass, NULL, am_sqlite3_database_free, am_db);
    return obj;
}

/**
 * Document-class: Amalgalite::SQLite3::Database
 *
 * The ruby extension wrapper around the core sqlite3 database object.
 *
 */
void Init_amalgalite3_database( )
{

    VALUE ma  = rb_define_module("Amalgalite");
    VALUE mas = rb_define_module_under(ma, "SQLite3");

    /*
     * Encapsulate an SQLite3 database
     */
    cAS_Database = rb_define_class_under( mas, "Database", rb_cObject);

    rb_define_alloc_func(cAS_Database, am_sqlite3_database_alloc);
    rb_define_singleton_method(cAS_Database, "open", am_sqlite3_database_open, -1);
    rb_define_singleton_method(cAS_Database, "open16", am_sqlite3_database_open16, 1);
    rb_define_method(cAS_Database, "prepare", am_sqlite3_database_prepare, 1);
    rb_define_method(cAS_Database, "close", am_sqlite3_database_close, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "last_insert_rowid", am_sqlite3_database_last_insert_rowid, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "autocommit?", am_sqlite3_database_is_autocommit, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "register_trace_tap", am_sqlite3_database_register_trace_tap, 1); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "register_profile_tap", am_sqlite3_database_register_profile_tap, 1); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "table_column_metadata", am_sqlite3_database_table_column_metadata, 3); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "row_changes", am_sqlite3_database_row_changes, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "total_changes", am_sqlite3_database_total_changes, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "last_error_code", am_sqlite3_database_last_error_code, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "last_error_message", am_sqlite3_database_last_error_message, 0); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "define_function", am_sqlite3_database_define_function, 2); /* in amalgalite3_database.c */
    rb_define_method(cAS_Database, "remove_function", am_sqlite3_database_remove_function, 2); /* in amalgalite3_database.c */


    /*
     * Ecapuslate a SQLite3 Database stat
     */
    cAS_Database_Stat = rb_define_class_under( cAS_Database, "Stat", rb_cObject );
    rb_define_method(cAS_Database_Stat, "update!", am_sqlite3_database_stat_update_bang, -1); /* in amalgalite3_database.c */

}

