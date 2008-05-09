#include "amalgalite3.h"
/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

/***********************************************************************
 * Ruby life cycle methods
 ***********************************************************************/


/*
 * garbage collector free method for the am_sqlite3_statement tructure
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


