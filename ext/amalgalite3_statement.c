#include "amalgalite3.h"
/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

/**
 * :call-seq:
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
 * :call-seq:
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
 * :call-seq:
 *    stmt.step -> int
 *
 */
VALUE am_sqlite3_statement_step(VALUE self)
{
    am_sqlite3_stmt  *am_stmt;
    
    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);
    return INT2FIX( sqlite3_step( am_stmt->stmt ) );
}

/**
 * :call-seq:
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
 * :call-seq:
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
 * :call-seq:
 *    stmt.column_value( index ) -> String
 *  
 * Return the column value at the ith column in the result set.  The left-most column
 * is number 0.
 *
 */
VALUE am_sqlite3_statement_column_value(VALUE self, VALUE v_idx)
{
    am_sqlite3_stmt   *am_stmt;
    int               idx = FIX2INT( v_idx );

    Data_Get_Struct(self, am_sqlite3_stmt, am_stmt);

    return rb_str_new2( (const char *)sqlite3_column_text( am_stmt->stmt, idx ) );
}



/**
 * :call-seq:
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
 * :call-seq:
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
}

/***********************************************************************
 * Ruby life cycle methods
 ***********************************************************************/


/*
 * garbage collector free method for the am_sqlite3_statement structure
 */
void am_sqlite3_statement_free(am_sqlite3_stmt* wrapper)
{

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


