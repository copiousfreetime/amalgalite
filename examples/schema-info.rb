#!/usr/bin/env ruby

require 'rubygems'
require 'amalgalite'

db_name = ARGV.shift
unless db_name 
  puts "Usage: #{File.basename($0)} dbname" 
  exit 1
end
db = Amalgalite::Database.new( db_name )
col_info = %w[ default_value declared_data_type collation_sequence_name not_null_constraint primary_key auto_increment ]
max_width = col_info.collect { |c| c.length }.sort.last

db.schema.tables.keys.sort.each do |table_name|
  puts "Table: #{table_name}"
  puts "=" * 42
  db.schema.tables[table_name].columns.each_pair do |col_name, col|
    puts "  Column : #{col.name}"
    col_info.each do |ci|
      puts "    |#{ci.rjust( max_width, "." )} : #{col.send( ci )}"
    end
    puts 
  end

  db.schema.tables[table_name].indexes.each_pair do |idx_name, index|
    puts "  Index : #{index.name}"
    puts "    |#{"sequence_number".rjust( max_width, "." )} : #{index.sequence_number}"
    puts "    |#{"is unique?".rjust( max_width, ".")} : #{index.unique?}"
    puts "    |#{"columns".rjust( max_width, ".")} : #{index.columns.collect { |c| c.name }.join(',') }"
    puts
  end
end

