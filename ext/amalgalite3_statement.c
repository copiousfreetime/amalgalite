#include "amalgalite3.h"
/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

VALUE cAS_Statement;   /* class  Amalgliate::SQLite3::Statement */

/**
 * call-seq:
 *     stmt.bind_null( position ) -> int
 * 
 * bind a null value to the variable at postion.
 *
 */
VALUE am_sqlite3_statement_bind_null(VALUE self, VALUE position )
{
    am_sqlite3_stmt  *am_stmt;
    int               pos = FIX2INT( position );
    int               rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_bind_null( am_stmt->stmt, pos );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error binding NULL at position %d in statement: [SQLITE_ERROR %d] : %s\n",
                pos,
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return INT2FIX(rc);
}

/**
 * call-seq:
 *    stmt.bind_zeroblob( position, length ) -> int
 *
 * bind a blob with +length+ filled with zeros to the position.  This is a Blob
 * that will later filled in with incremental IO routines.
 */
VALUE am_sqlite3_statement_bind_zeroblob( VALUE self, VALUE position, VALUE length)
{
    am_sqlite3_stmt  *am_stmt;
    int               pos = FIX2INT( position );
    int               n = FIX2INT( length );
    int               rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_bind_zeroblob( am_stmt->stmt, pos, n );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error binding zeroblob of length %d at position %d in statement: [SQLITE_ERROR %d] : %s\n",
                n, pos,
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return INT2FIX(rc);
}


/**
 * call-seq:
 *    stmt.bind_blob( position, blob ) -> int
 *
 * bind a blob to the variable at position.  This is a blob that is fully held
 * in memory
 */
VALUE am_sqlite3_statement_bind_blob( VALUE self, VALUE position, VALUE blob )
{
    am_sqlite3_stmt  *am_stmt;
    int               pos = FIX2INT( position );
    VALUE             str = StringValue( blob );
    int               rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_bind_blob( am_stmt->stmt, pos, RSTRING( str )->ptr, RSTRING( str )->len, SQLITE_TRANSIENT);
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error binding blob at position %d in statement: [SQLITE_ERROR %d] : %s\n",
                pos,
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return INT2FIX(rc);
}

/**
 * call-seq:
 *     stmt.bind_double( position, value ) -> nil
 * 
 * bind a double value to the variable at postion.
 *
 */
VALUE am_sqlite3_statement_bind_double(VALUE self, VALUE position, VALUE value)
{
    am_sqlite3_stmt  *am_stmt;
    int               pos = FIX2INT( position );
    double            v   = NUM2DBL( value );
    int               rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_bind_double( am_stmt->stmt, pos, v );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error binding [%s] to double at position %d in statement: [SQLITE_ERROR %d] : %s\n",
                value, pos,
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return INT2FIX(rc);
}
 
/**
 * call-seq:
 *     stmt.bind_int( position, value ) -> nil
 * 
 * bind a int value to the variable at postion.
 *
 */
VALUE am_sqlite3_statement_bind_int(VALUE self, VALUE position, VALUE value)
{
    am_sqlite3_stmt  *am_stmt;
    int               pos = FIX2INT( position );
    int               v   = NUM2INT( value );
    int               rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_bind_int( am_stmt->stmt, pos, v );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error binding [%s] to int at position %d in statement: [SQLITE_ERROR %d] : %s\n",
                v, pos,
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return INT2FIX(rc);
}
 
/**
 * call-seq:
 *     stmt.bind_int64( position, value ) -> nil
 * 
 * bind a int64 value to the variable at postion.
 *
 */
VALUE am_sqlite3_statement_bind_int64(VALUE self, VALUE position, VALUE value)
{
    am_sqlite3_stmt  *am_stmt;
    int               pos = FIX2INT( position );
    sqlite3_int64     v   = NUM2SQLINT64( value );
    int               rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_bind_int64( am_stmt->stmt, pos, v );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error binding [%s] to int64 at position %d in statement: [SQLITE_ERROR %d] : %s\n",
                v, pos,
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return INT2FIX(rc);
}
 
/**
 * call-seq:
 *     stmt.bind_text( position, value ) -> nil
 * 
 * bind a string value to the variable at postion.
 *
 */
VALUE am_sqlite3_statement_bind_text(VALUE self, VALUE position, VALUE value)
{
    am_sqlite3_stmt  *am_stmt;
    int               pos = FIX2INT( position );
    VALUE             str = StringValue( value );
    int               rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_bind_text( am_stmt->stmt, pos, RSTRING(str)->ptr, RSTRING(str)->len, SQLITE_TRANSIENT);
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error binding [%s] to text at position %d in statement: [SQLITE_ERROR %d] : %s\n",
                RSTRING(str)->ptr, pos,
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return INT2FIX(rc);
}
/**
 * call-seq:
 *    stmt.remaining_sql -> String
 *
 * returns the remainging SQL leftover from the initialization sql, or nil if
 * there is no remaining SQL
 */
VALUE am_sqlite3_statement_remaining_sql(VALUE self)
{
    am_sqlite3_stmt  *am_stmt;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return am_stmt->remaining_sql;
}
/**
 * call-seq:
 *    stmt.parameter_index( name ) -> Integer
 *
 * returns the index of the named parameter from the statement.  Used to help
 * with the :VVV, @VVV and $VVV pareamter replacement styles.
 */
VALUE am_sqlite3_statement_bind_parameter_index(VALUE self, VALUE parameter_name)
{
    am_sqlite3_stmt  *am_stmt;
    int               idx;
    
    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    idx = sqlite3_bind_parameter_index( am_stmt->stmt, StringValuePtr( parameter_name ));
    return INT2FIX( idx );
}

/**
 * call-seq:
 *    stmt.parameter_count -> Integer
 *
 * return the index of the largest parameter in the in the statement.  For all
 * forms except ?NNN this is the number of unique parameters.  Using ?NNN can
 * create gaps in the list of parameters.
 *
 */
VALUE am_sqlite3_statement_bind_parameter_count(VALUE self)
{
    am_sqlite3_stmt  *am_stmt;
    
    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return INT2FIX(sqlite3_bind_parameter_count( am_stmt->stmt ) );
}

/**
 * call-seq:
 *    stmt.reset! -> nil
 *
 * reset the SQLite3 statement back to its initial state.
 */
VALUE am_sqlite3_statement_reset(VALUE self)
{
    am_sqlite3_stmt  *am_stmt;
    int               rc;
    
    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_reset( am_stmt->stmt );
    if ( rc != SQLITE_OK ) {
        rb_raise(eAS_Error, "Error resetting statement: [SQLITE_ERROR %d] : %s\n",
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }
    return Qnil;
}

/**
 * call-seq:
 *    stmt.clear_bindings! -> nil
 *
 * reset the SQLite3 statement back to its initial state.
 */
VALUE am_sqlite3_statement_clear_bindings(VALUE self)
{
    am_sqlite3_stmt  *am_stmt;
    int               rc;
    
    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_clear_bindings( am_stmt->stmt );
    if ( rc != SQLITE_OK ) {
        rb_raise(eAS_Error, "Error resetting statement: [SQLITE_ERROR %d] : %s\n",
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }
    return Qnil;
}


/**
 * call-seq:
 *    stmt.step -> int
 *
 * Step through the next piece of the SQLite3 statement
 *
 */
VALUE am_sqlite3_statement_step(VALUE self)
{
    am_sqlite3_stmt  *am_stmt;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return INT2FIX( sqlite3_step( am_stmt->stmt ) );
}

/**
 * call-seq:
 *    stmt.column_count -> Fixnum
 *
 * return the number of columns in the result set.
 *
 */
VALUE am_sqlite3_statement_column_count(VALUE self)
{
    am_sqlite3_stmt  *am_stmt;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return INT2FIX( sqlite3_column_count( am_stmt->stmt ) );
}

/**
 * call-seq:
 *    stmt.column_name( index ) -> String
 *  
 * Return the column name at the ith column in the result set.  The left-most column
 * is number 0.
 *
 */
VALUE am_sqlite3_statement_column_name(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt  *am_stmt;
    int               idx = FIX2INT( v_idx );
    
    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);

    return rb_str_new2( sqlite3_column_name( am_stmt->stmt, idx ) );
}


/**
 * call-seq:
 *    stmt.column_declared_type( index ) -> String
 *  
 * Return the declared type of the ith column in the result set.  This is the
 * value that was in the original CREATE TABLE statement.
 *
 */
VALUE am_sqlite3_statement_column_decltype(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int                idx = FIX2INT( v_idx );
    const char        *decltype; 

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    decltype = sqlite3_column_decltype( am_stmt->stmt, idx ) ;
    if ( NULL == decltype) {
        return Qnil;
    } else {
        return rb_str_new2( decltype );
    }
}

/**
 * call-seq:
 *    stmt.column_type( index ) -> SQLite3::DataType constant
 *  
 * Return the column type at the ith column in the result set.  The left-most column
 * is number 0.
 *
 */
VALUE am_sqlite3_statement_column_type(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return INT2FIX( sqlite3_column_type( am_stmt->stmt, idx ) );
}

/**
 * call-seq:
 *    stmt.column_text( index ) -> String
 *  
 * Return the data in ith column of the result as a String.
 *
 */
VALUE am_sqlite3_statement_column_text(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return rb_str_new2( (const char*)sqlite3_column_text( am_stmt->stmt, idx ) );
}

/**
 * call-seq:
 *    stmt.column_blob( index ) -> String
 *  
 * Return the data in ith column of the result as a String.
 *
 */
VALUE am_sqlite3_statement_column_blob(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt *am_stmt;
    int              idx    = FIX2INT( v_idx );
    const char      *data; 
    long             length;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    data = sqlite3_column_blob( am_stmt->stmt, idx );
    length = sqlite3_column_bytes( am_stmt->stmt, idx );
    return rb_str_new( data, length );

}


/**
 * call-seq:
 *    stmt.column_double( index ) -> Float
 *  
 * Return the data in ith column of the result as an Float
 *
 */
VALUE am_sqlite3_statement_column_double(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return rb_float_new( sqlite3_column_double( am_stmt->stmt, idx )) ;
}


/**
 * call-seq:
 *    stmt.column_int( index ) -> Integer
 *  
 * Return the data in ith column of the result as an Integer
 *
 */
VALUE am_sqlite3_statement_column_int(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return INT2NUM( sqlite3_column_int( am_stmt->stmt, idx )) ;
}


/**
 * call-seq:
 *    stmt.column_int64( index ) -> Integer
 *  
 * Return the data in ith column of the result as an Integer
 *
 */
VALUE am_sqlite3_statement_column_int64(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return SQLINT64_2NUM( sqlite3_column_int64( am_stmt->stmt, idx )) ;
}



/**
 * call-seq:
 *    stmt.column_database_name( index ) -> String
 *  
 * Return the database name where the data in the ith column of the result set
 * comes from.
 *
 */
VALUE am_sqlite3_statement_column_database_name(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );
    const char        *n ;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    n = sqlite3_column_database_name( am_stmt->stmt, idx ) ;
    return ( n == NULL ? Qnil : rb_str_new2( n ) ); 
}

/**
 * call-seq:
 *    stmt.column_table_name( index ) -> String
 *  
 * Return the table name where the data in the ith column of the result set
 * comes from.
 *
 */
VALUE am_sqlite3_statement_column_table_name(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );
    const char        *n ;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    n =  sqlite3_column_table_name( am_stmt->stmt, idx );
    return ( n == NULL ? Qnil : rb_str_new2( n ) ); 
}


/**
 * call-seq:
 *    stmt.column_origin_name( index ) -> String
 *  
 * Return the column name where the data in the ith column of the result set
 * comes from.
 *
 */
VALUE am_sqlite3_statement_column_origin_name(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );
    const char        *n ;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    n = sqlite3_column_origin_name( am_stmt->stmt, idx );
    return ( n == NULL ? Qnil : rb_str_new2( n ) ); 
}


/**
 * call-seq:
 *    stmt.sql -> String
 *
 * Return a copy of the original string used to create the prepared statement.
 */
VALUE am_sqlite3_statement_sql(VALUE self)
{

    am_sqlite3_stmt   *am_stmt;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return rb_str_new2( sqlite3_sql( am_stmt->stmt ) );
    
}

/**
 * call-seq:
 *    stmt.close -> nil
 *
 * Closes the statement.  If there is a problem closing the statement then an
 * error is raised.
 */
VALUE am_sqlite3_statement_close( VALUE self )
{

    am_sqlite3_stmt   *am_stmt;
    int                rc;

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    rc = sqlite3_finalize( am_stmt->stmt );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Failure to close statment : [SQLITE_ERROR %d] : %s\n",
                rc, sqlite3_errmsg( sqlite3_db_handle( am_stmt->stmt) ));
    }

    return Qnil;
}

/***********************************************************************
 * Ruby life cycle methods
 ***********************************************************************/


/*
 * garbage collector free method for the am_sqlite3_statement structure
 */
void am_sqlite3_statement_free(am_sqlite3_stmt* wrapper)
{

    if ( Qnil != wrapper->remaining_sql ) {
        rb_gc_unregister_address( &(wrapper->remaining_sql) );
        wrapper->remaining_sql = Qnil;
    }
    free(wrapper);
    return;
}

/*
 * allocate the am_data structure
 */
VALUE am_sqlite3_statement_alloc(VALUE klass)
{
    am_sqlite3_stmt  *wrapper = ALLOC(am_sqlite3_stmt);
    VALUE             obj     = (VALUE)NULL;

    obj = Data_Wrap_Struct(klass, NULL, am_sqlite3_statement_free, wrapper);
    return obj;
}

/**
 * Amagalite Database extension
 */

void Init_amalgalite3_statement( )
{

    VALUE ma  = rb_define_module("Amalgalite");
    VALUE mas = rb_define_module_under(ma, "SQLite3");

    /*
     * Encapsulate the SQLite3 Statement handle in a class
     */
    cAS_Statement = rb_define_class_under( mas, "Statement", rb_cObject ); 
    rb_define_alloc_func(cAS_Statement, am_sqlite3_statement_alloc); 
    rb_define_method(cAS_Statement, "sql", am_sqlite3_statement_sql, 0); 
    rb_define_method(cAS_Statement, "close", am_sqlite3_statement_close, 0); 
    rb_define_method(cAS_Statement, "step", am_sqlite3_statement_step, 0); 

    rb_define_method(cAS_Statement, "column_count", am_sqlite3_statement_column_count, 0); 
    rb_define_method(cAS_Statement, "column_name", am_sqlite3_statement_column_name, 1); 
    rb_define_method(cAS_Statement, "column_declared_type", am_sqlite3_statement_column_decltype, 1); 
    rb_define_method(cAS_Statement, "column_type", am_sqlite3_statement_column_type, 1); 
    rb_define_method(cAS_Statement, "column_text", am_sqlite3_statement_column_text, 1); 
    rb_define_method(cAS_Statement, "column_blob", am_sqlite3_statement_column_blob, 1); 
    rb_define_method(cAS_Statement, "column_int", am_sqlite3_statement_column_int, 1); 
    rb_define_method(cAS_Statement, "column_int64", am_sqlite3_statement_column_int64, 1); 
    rb_define_method(cAS_Statement, "column_double", am_sqlite3_statement_column_double, 1); 

    rb_define_method(cAS_Statement, "column_database_name", am_sqlite3_statement_column_database_name, 1); 
    rb_define_method(cAS_Statement, "column_table_name", am_sqlite3_statement_column_table_name, 1); 
    rb_define_method(cAS_Statement, "column_origin_name", am_sqlite3_statement_column_origin_name, 1); 
    rb_define_method(cAS_Statement, "reset!", am_sqlite3_statement_reset, 0); 
    rb_define_method(cAS_Statement, "clear_bindings!", am_sqlite3_statement_clear_bindings, 0); 
    rb_define_method(cAS_Statement, "parameter_count", am_sqlite3_statement_bind_parameter_count, 0); 
    rb_define_method(cAS_Statement, "parameter_index", am_sqlite3_statement_bind_parameter_index, 1); 
    rb_define_method(cAS_Statement, "remaining_sql", am_sqlite3_statement_remaining_sql, 0); 
    rb_define_method(cAS_Statement, "bind_text", am_sqlite3_statement_bind_text, 2); 
    rb_define_method(cAS_Statement, "bind_int", am_sqlite3_statement_bind_int, 2); 
    rb_define_method(cAS_Statement, "bind_int64", am_sqlite3_statement_bind_int64, 2); 
    rb_define_method(cAS_Statement, "bind_double", am_sqlite3_statement_bind_double, 2); 
    rb_define_method(cAS_Statement, "bind_null", am_sqlite3_statement_bind_null, 1); 
    rb_define_method(cAS_Statement, "bind_blob", am_sqlite3_statement_bind_blob, 2); 
    rb_define_method(cAS_Statement, "bind_zeroblob", am_sqlite3_statement_bind_zeroblob, 2); 
}


