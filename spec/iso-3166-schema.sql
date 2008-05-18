
-- SET client_encoding TO 'UNICODE';

CREATE TABLE country (
    name TEXT NOT NULL,
    two_letter TEXT PRIMARY KEY,
    id integer NOT NULL
);
CREATE INDEX country_name  ON country(name);


CREATE TABLE subcountry (
    country TEXT NOT NULL REFERENCES country(two_letter),
    name TEXT NOT NULL,
    subdivision TEXT,
    level TEXT,
    UNIQUE(country, name)
);

CREATE INDEX subcountry_country ON subcountry(country);
CREATE INDEX subcountry_name ON subcountry(name);

