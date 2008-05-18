#!/bin/sh

DB="iso-3166.db"
SCHEMA="iso-3166-schema.sql"

rm -f ${DB}
sqlite3 ${DB} < ${SCHEMA}
echo ".import iso-3166-country.txt country" | sqlite3 ${DB} 
echo ".import iso-3166-subcountry.txt subcountry" | sqlite3 ${DB} 

sqlite3 ${DB} "select 'country_count',  count(1) from country"
sqlite3 ${DB} "select 'subcountry_count', count(1) from subcountry"
