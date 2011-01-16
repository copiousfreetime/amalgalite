#include "amalgalite3.h"
/**
 * Copyright (c) 2008 Jeremy Hinegardner
 * All rights reserved.  See LICENSE and/or COPYING for details.
 *
 * vim: shiftwidth=4 
 */ 

/* class  Amalgliate::SQLite3::Blob */
VALUE cAS_Blob;   

/**
 * call-seq:
 *   Blob.new( database, table_name, column_name, row_id, flag ) -> Blob
 *
 * Create a new Blob object and associate it with the approriate, database,
 * table, column and row.  +flag+ indicates if the Blob is to be opened for
 * writing "w" or reading "r".
 *
 */
VALUE am_sqlite3_blob_initialize( VALUE self, VALUE db, VALUE db_name, VALUE table_name, VALUE column_name, VALUE rowid, VALUE flag) 
{
    am_sqlite3_blob *am_blob;
    int              rc;
    am_sqlite3      *am_db;
    char            *zDb      = StringValuePtr( db_name );
    char            *zTable   = StringValuePtr( table_name );
    char            *zColumn  = StringValuePtr( column_name );
    sqlite3_int64    iRow     = NUM2SQLINT64( rowid )  ;
    VALUE            flag_str = StringValue( flag );
    int              flags    = 0;

    /* extract the blob struct */
    Data_Get_Struct(self, am_sqlite3_blob, am_blob);
    
    /* extract the sqlite3 db struct */
    Data_Get_Struct(db, am_sqlite3, am_db);

    /* make sure that the flags are valid, only 'r' or 'w' are allowed */
    if ( ( RSTRING_LEN( flag_str ) != 1) || 
         ( ( 'r' != RSTRING_PTR( flag_str )[0] ) && 
           ( 'w' != RSTRING_PTR( flag_str )[0] ))) {
        rb_raise( eAS_Error, "Error opening Blob in db = %s, table = %s, column = %s, rowid = %lu.  Invalid flag '%s'.  Must be either 'w' or 'r'\n",
                             zDb, zTable, zColumn, (unsigned long)iRow, RSTRING_PTR( flag_str ));
    }

    /* switch to write mode */
    if ( 'w' == RSTRING_PTR( flag_str )[0] ) { 
        flags = 1;
    }

    /* open the blob and associate the db to it */
    rc = sqlite3_blob_open( am_db->db, zDb, zTable, zColumn, iRow, flags, &( am_blob->blob ) );
    if ( SQLITE_OK != rc ) {
        rb_raise( eAS_Error, "Error opening Blob in db = %s, table = %s, column = %s, rowid = %lu : [SQLITE_ERROR %d] %s\n", zDb, zTable, zColumn, (unsigned long)iRow, rc, sqlite3_errmsg( am_db->db) );  
    }
    am_blob->length = sqlite3_blob_bytes( am_blob->blob );
    am_blob->db = am_db->db;

    /* if a block is given then yield self and close the blob when done */
    if ( rb_block_given_p() ) {
        rb_yield( self );
        am_sqlite3_blob_close( self );
        return Qnil;
    } else {
        return self;
    }
}

/**
 * call-seq:
 *  blob.close -> nil
 *
 * Closes the blob.
 */
VALUE am_sqlite3_blob_close( VALUE self )
{
    am_sqlite3_blob *am_blob;
    int              rc;
    
    Data_Get_Struct(self, am_sqlite3_blob, am_blob);
    rc = sqlite3_blob_close( am_blob->blob );
    if ( SQLITE_OK != rc ) {
        rb_raise(eAS_Error, "Error closing blob: [SQLITE_ERROR %d] %s\n",
                rc, sqlite3_errmsg( am_blob->db ));
    }


    return Qnil;
}


/**
 * call-seq:
 *  blob.length -> length in bytes of the blob
 *
 * Returns the number of bytes in the blob.
 */
VALUE am_sqlite3_blob_length( VALUE self )
{
    am_sqlite3_blob *am_blob;

    Data_Get_Struct(self, am_sqlite3_blob, am_blob);

    return INT2FIX( am_blob->length );
}

/**
 * call-seq:
 *   blob.read( int ) -> String containting int number of  bytes or nil if eof.
 *
 * returns int number of bytes as a String from the database
 */
VALUE am_sqlite3_blob_read( VALUE self, VALUE length )
{
    am_sqlite3_blob *am_blob;
    int             rc;
    int              n = NUM2INT( length );
    void           *buf = NULL;
    VALUE          result;

    Data_Get_Struct(self, am_sqlite3_blob, am_blob);

    /* we have to be exact on the number of bytes to read.  n + current_offset
     * cannot be larger than the blob's length
     */
    if ( (n + am_blob->current_offset > am_blob->length)) {
        n = am_blob->length - am_blob->current_offset;
    }

    if ( am_blob->current_offset == am_blob->length ) {
        return Qnil;
    }

    buf = (void *)malloc( n );
    rc = sqlite3_blob_read( am_blob->blob, buf, n, am_blob->current_offset); 

    if ( rc != SQLITE_OK ) {
        rb_raise(eAS_Error, "Error reading %d bytes blob at offset %d: [SQLITE_ERROR %d] %s\n",
                n, am_blob->current_offset, rc, sqlite3_errmsg( am_blob->db ));
    }

    am_blob->current_offset += n;

    result = rb_str_new( (char*)buf, n );
    free( buf );
    return result;

}

/**
 * call-seq:
 *   blob.write( buf ) -> int
 *
 * writes the contents of the string buffer to the blob and returns the number
 * of bytes written.
 *
 */
VALUE am_sqlite3_blob_write( VALUE self, VALUE buf )
{
    am_sqlite3_blob *am_blob;
    int              rc;
    VALUE            str = StringValue( buf );
    int              n   = (int)RSTRING_LEN( str );
    char            *chk_buf = NULL;

    Data_Get_Struct(self, am_sqlite3_blob, am_blob);

    rc = sqlite3_blob_write( am_blob->blob, RSTRING_PTR(str), n, am_blob->current_offset); 

    if ( rc  != SQLITE_OK ) {
        rb_raise(eAS_Error, "Error writing %d bytes blob at offset %d: [SQLITE_ERROR %d] %s\n",
                n, am_blob->current_offset, rc, sqlite3_errmsg( am_blob->db ));
    }

    chk_buf = (char *) malloc( n  + 1);
    chk_buf[n] = '\0';
    sqlite3_blob_read( am_blob->blob, chk_buf, n, 0);

    am_blob->current_offset += n;

    return INT2FIX( n );

}


/***********************************************************************
 * Ruby life cycle methods
 ***********************************************************************/

/*
 * garbage collector free method for the am_sqlite3_blob structure
 */
void am_sqlite3_blob_free(am_sqlite3_blob* wrapper)
{
    free(wrapper);
    return;
}

/*
 * allocate the am_blob structure
 */
VALUE am_sqlite3_blob_alloc(VALUE klass)
{
    am_sqlite3_blob  *wrapper = ALLOC( am_sqlite3_blob );
    VALUE             obj     ; 

    wrapper->current_offset = 0;
    wrapper->db             = NULL;
    obj = Data_Wrap_Struct(klass, NULL, am_sqlite3_blob_free, wrapper);
    return obj;
}


/**
 * Document-class: Amalgalite::SQLite3::Blob
 *
 * The Blob class enables incremental IO on blob items.  If you do not need
 * incremental IO on a binary object, then you do not need to use Blob.
 */

void Init_amalgalite3_blob( )
{

    VALUE ma  = rb_define_module("Amalgalite");
    VALUE mas = rb_define_module_under(ma, "SQLite3");

    /*
     * Encapsulate the SQLite3 Statement handle in a class
     */
    cAS_Blob = rb_define_class_under( mas, "Blob", rb_cObject ); 
    rb_define_alloc_func(cAS_Blob, am_sqlite3_blob_alloc); 
    rb_define_method(cAS_Blob, "initialize", am_sqlite3_blob_initialize, 6); 
    rb_define_method(cAS_Blob, "close", am_sqlite3_blob_close, 0); 
    rb_define_method(cAS_Blob, "read", am_sqlite3_blob_read, 1); 
    rb_define_method(cAS_Blob, "write", am_sqlite3_blob_write, 1); 
    rb_define_method(cAS_Blob, "length", am_sqlite3_blob_length, 0); 
}


