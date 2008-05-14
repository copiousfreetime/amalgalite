#include "amalgalite3.h"
/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

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


