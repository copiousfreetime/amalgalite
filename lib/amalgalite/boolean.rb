#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
module Amalgalite
  ##
  # Do type conversion on values that could be boolen values into 
  # real 'true' or 'false'
  #
  # This is pulled from the possible boolean values from PostgreSQL
  #
  class Boolean
    class << self
      #
      # list of downcased strings are potential true values
      # 
      def true_values
        @true_values ||= %w[ true t yes y 1 ]
      end

      #
      # list of downcased strings are potential false values
      #
      def false_values
        @false_values ||= %w[ false f no n 0 ]
      end

      # 
      # Convert +val+ to a string and attempt to convert it to +true+ or +false+
      #
      def to_bool( val )
        return false if val.nil?
        unless defined? @to_bool
          @to_bool = {}
          true_values.each  { |t| @to_bool[t] = true  }
          false_values.each { |f| @to_bool[f] = false }
        end
        return @to_bool[val.to_s.downcase]
      end
    end
  end
end
