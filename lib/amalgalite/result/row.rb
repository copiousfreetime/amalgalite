#--
# Copyright (c) 2025 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Amalgalite
  class Result
    ##
    # The class that represents a single row from a query.
    #
    class Row
      # The result object this row is retrivved from, nil if all values
      # are materialized
      attr_reader :result

      # A Hash that maps the field names to indexes in values
      # This may be linked to shared field from the result
      attr_reader :field_map

      # An array containing the values from the row
      attr_reader :values
      alias to_a values

      def initialize(result: nil, field_map:, values:)
        @result = result
        @field_map = field_map
        @values = values
        self.freeze
      end

      def fields
        @field_map.keys
      end

      def store(field_name_or_index, value)
        index = field_name_or_index_to_index(field_name_or_index)
        values[index] = value
      end
      alias []= store

      def fetch(field_name_or_index)
        case field_name_or_index
        when Integer
          values[field_name_or_index]
        when Symbol, String
          values[field_map[field_name_or_index]]
        else
          raise Amalgalite::Error, "Unknown type (#{field_name_or_index.class}) of key for a Row value: #{field_name_or_index}"
        end
      end
      alias [] fetch

      def first
        fetch(0)
      end

      def length
        values.size
      end

      def to_h
        Hash[field_map.keys.zip(values)]
      end

      private

      def field_name_or_index_to_index(field_name_or_index)
        case field_name_or_index
        when Integer
          field_name_or_index
        when Symbol, String
          values[field_map[field_name_or_index]]
        else
          raise Amalgalite::Error, "Unknown type (#{field_name_or_index.class}) of key for a Row value: #{field_name_or_index}"
        end
      end
    end
  end
end
