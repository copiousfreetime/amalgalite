#ifndef __AMALGALITE_H__
#define __AMALGALITE_H__

#include "ruby.h"
#include "sqlite3.h"

/** module and classes **/
extern VALUE mAmalgalite;
extern VALUE cAmalgalite_DB;
extern VALUE cAmalgalite_Statement;
extern VALUE cAmalgalite_Blob;

/***********************************************************************
 * Prototypes
 **********************************************************************/
void am_define_constants_under(VALUE);

/***********************************************************************
 * Helpful macros
 **********************************************************************/

#define SQLINT64_2NUM(x)      ( LL2NUM( x ) )
#define SQLUINT64_2NUM(x)     ( ULL2NUM( x ) )
#define NUM2SQLINT64( obj )   ( NUM2LL( obj ) )
#define NUM2SQLUINT64( obj )  ( NUM2ULL( obj ) )
#endif
