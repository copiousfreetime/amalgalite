#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
module Amalgalite
  
  ##
  # Do type conversion on values that coule be boolen values into True or False 
  #
  # This is pulled from the possible boolean values from PostgreSQL
  #
  class Boolean
    class << self
      def true_values
        @true_values ||= %w[ true t yes y 1 ]
      end

      def false_values
        @false_values ||= %w[ false f no n 0 ]
      end

      def to_bool( val )
        return false if val.nil?
        unless @to_bool
          @to_bool = {}
          true_values.each  { |t| @to_bool[t] = true  }
          false_values.each { |f| @to_bool[f] = false }
        end
        return @to_bool[val.to_s.downcase]
      end
    end
  end
end
