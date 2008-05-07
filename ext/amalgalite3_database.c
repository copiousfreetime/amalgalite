#include "amalgalite3.h"
/* 
 * vim: shiftwidth=4 
 */ 

/**
 * :call-seq:
 *    Amalagliate::SQLite3::Database.open( filename, flags = READWRITE | CREATE ) -> Database
 *
 * Create a new SQLite3 database with a UTF-8 encoding.
 *
 */ 
VALUE am_sqlite3_database_open(int argc, VALUE *argv, VALUE self)
{
    VALUE  new_self = am_sqlite3_database_alloc(self);
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
    Data_Get_Struct(new_self, am_sqlite3, am_db);

    /* open the sqlite3 database */
    rc = sqlite3_open_v2( filename, &(am_db->db), flags, 0);
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Failure to open database %s : [SQLITE_ERROR %d] : %s\n",
                filename, rc, sqlite3_errmsg(am_db->db));
    }

    return self;
}

/***********************************************************************
 * Ruby life cycle methods
 ***********************************************************************/


/*
 * garbage collector free method for the am_data structure
 */
void am_sqlite3_database_free(am_sqlite3* wrapper)
{
    free(wrapper);
    return;
}

/*
 * allocate gor the am_data structure
 */
VALUE am_sqlite3_database_alloc(VALUE klass)
{
    am_sqlite3*  wrapper = ALLOC(am_sqlite3);
    VALUE   obj  = (VALUE)NULL;

    obj = Data_Wrap_Struct(klass, NULL, am_sqlite3_database_free, wrapper);
    return obj;
}
