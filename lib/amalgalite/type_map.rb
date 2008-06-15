#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
module Amalgalite
  ##
  # TypeMap defines the protocol used between Ruby and SQLite for mapping
  # binding types, used in prepared statements; and result types, used in
  # returning objects from a query.
  #
  #
  class TypeMap
    ##
    # :call-seq:
    #   map.bind_type_of( obj ) -> DataType constant
    #
    # bind_type_of is called during the Statement#bind process to convert the
    # bind parameter to the appropriate SQLite types.  This method MUST return
    # one of the valid constants in the namespace 
    # Amalgalite::SQLite::Constants::DataType
    #
    def bind_type_of( obj )
      raise NotImplementedError, "bind_type_of has not been implemented"
    end

    ##
    # :call-seq:
    #   map.result_value_of( declared_type, value ) -> String
    #
    # result_value_of is called during the result processing of column values 
    # to convert an SQLite database value into the appropriate Ruby class.  
    #
    # +declared_type+ is the string from the original CREATE TABLE statment 
    # from which the column value originates.  It may also be nil if the origin
    # column cannot be determined.
    #
    # +value+ is the SQLite value from the column as either a Ruby String,
    # Integer, Float or Amalgalite::Blob. 
    #
    # result_value should return the value that is to be put into the result set
    # for the query.  It may do nothing, or it may do massive amounts of
    # conversion. 
    def result_value_of( delcared_type, value )
      raise NotImplementedError, "result_value_of has not been implemented"
    end
  end 

  ##
  # The TypeMaps module holds all typemaps that ship with Amagalite.  They
  # currently are:
  #
  # DefaultMap:: does a 'best-guess' mapping to convert as many types as
  #              possible to known ruby classes from known SQL types.
  # StorageMap:: converts to a limited set of classes directly based 
  #              upon the SQLite storage types
  # TextMap::    Everything is Text ... everything everything everything
  #
  module TypeMaps
  end
end
