#include "amalgalite3.h"
/* 
 * vim: shiftwidth=4 
 */ 

/***********************************************************************
 * Prototypes
 ***********************************************************************/

/* Module and Classes */
VALUE mA;
VALUE mAS;
VALUE mASV;
VALUE cA_DB;
/** VALUE cAmalgalite_Statement; */
/** VALUE cAmalgalite_Blob; */

/*
 * return the sqlite3 version number as a string
 */
VALUE am_sqlite3_libversion(VALUE self)
{
    return rb_str_new2(sqlite3_libversion());
}

/*
 * return the sqlite3 version number as an integer
 */
VALUE am_sqlite3_libversion_number(VALUE self)
{
    return INT2FIX(sqlite3_libversion_number());
}

/***********************************************************************
 * Extension initialization
 ***********************************************************************/
void Init_amalgalite3()
{
    /*
     * module Amalgalite
     */
    mA = rb_define_module("Amalgalite");

    /* module Amalgalite::Sqlite3::Version and methods
     */
    mAS  = rb_define_module_under(mA, "Sqlite3");
    mASV = rb_define_module_under(mAS, "Version");
    rb_define_module_function(mASV, "to_s", am_sqlite3_libversion, 0);
    rb_define_module_function(mASV, "to_i", am_sqlite3_libversion_number, 0);


    /*
     * Amalgalite:: methods/constants for the module
     */

    /*
     * class DB
     */
    cA_DB = rb_define_class_under(mA, "DB", rb_cObject); 
}

