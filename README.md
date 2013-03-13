## Amalgalite

* [Homepage](http://github.com/copiousfreetime/amalgalite)
* email jeremy at copiousfreetime dot org
* `git clone git://github.com/copiousfreetime/amalgalite.git`
* [Github](http://github.com/copiousfreetime/amalgalite/)
* [Bug Tracking](http://github.com/copiousfreetime/amalgalite/issues)

## Articles

*  [Writing SQL Functions in Ruby](http://copiousfreetime.org/articles/2009/01/10/writing-sql-functions-in-ruby.html)

## INSTALL

* `gem install amalgalite`

## DESCRIPTION

Amalgalite embeds the SQLite database engine in a ruby extension.  There is no
need to install SQLite separately.  

Look in the examples/ directory to see

* general usage
* blob io
* schema information
* custom functions
* custom aggregates
* requiring ruby code from a database
* full text search

Also Scroll through Amalgalite::Database for a quick example, and a general
overview of the API.

Amalgalite adds in the following additional non-default SQLite extensions:

* [R*Tree index extension](http://sqlite.org/rtree.html)
* [Full Text Search](http://sqlite.org/fts3.html)

## BUILDING FOR WINDOWS

[rake-compiler](https://github.com/luislavena/rake-compiler) is use for building
the windows version. For me, on OSX to cross compile the process is:

```
% gem install rake-compiler # in each rvm instance, 1.8.7, 1.9.3
% rvm use 2.0.0@amalgalite
% rake-compiler cross-ruby VERSION=2.0.0-p0 # or latest
% rvm use 1.9.3@amalgalite
% rake-compiler cross-ruby VERSION=1.9.3-p374 # or latest
% rvm use 1.8.7@amalgalite
% rake-compiler cross-ruby VERSION=1.8.7-p371

# This only works via 1.8.7 at the current moment
% rake cross native gem RUBY_CC_VERSION=1.8.7:1.9.3:2.0.0
```


## CREDITS

* Jamis Buck for the first [ruby sqlite implementation](http://www.rubyforge.org/projects/sqlite-ruby)

## CHANGES

Read the HISTORY.rdoc file.

## LICENSE

Copyright (c) 2008 Jeremy Hinegardner

All rights reserved.

See LICENSE and/or COPYING for details.
