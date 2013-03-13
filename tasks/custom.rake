#-----------------------------------------------------------------------
# Custom tasks for this project
#-----------------------------------------------------------------------
require 'pathname'
namespace :util do
  desc "List the sqlite api calls that are not implemented"
  task :todo do

    not_implementing = %w[
      sqlite3_exec
      sqlite3_open
      sqlite3_os_end
      sqlite3_os_init
      sqlite3_malloc
      sqlite3_realloc
      sqlite3_free
      sqlite3_get_table
      sqlite3_free_table
      sqlite3_key
      sqlite3_rekey
      sqlite3_next_stmt
      sqlite3_release_memory
      sqlite3_sleep
      sqlite3_snprintf
      sqlite3_vmprintf
      sqlite3_strnicmp
      sqlite3_test_control
      sqlite3_unlock_notify
      sqlite3_vfs_find
      sqlite3_vfs_register
      sqlite3_vfs_unregister
    ]

    sqlite_h = File.join( *%w[ ext amalgalite c sqlite3.h ] )
    api_todo = {}
    IO.readlines( sqlite_h ).each do |line|
      if line =~ /\ASQLITE_API/ then
        if line !~ /SQLITE_DEPRECATED/ and line !~ /SQLITE_EXPERIMENTAL/ then
          if md = line.match( /(sqlite3_[^(\s]+)\(/ ) then
                                next if not_implementing.include?(md.captures[0])
                                api_todo[md.captures[0]] = true
          end
        end
      end
    end

    Dir.glob("ext/amalgalite/c/amalgalite*.c").each do |am_file|
      IO.readlines( am_file ).each do |am_line|
        if md = am_line.match( /(sqlite3_[^(\s]+)\(/ ) then
                                 api_todo.delete( md.captures[0] )
        end
      end
    end

    puts "#{api_todo.keys.size} functions to still implement"
    puts api_todo.keys.sort.join("\n")
  end

  desc "Download and integrate the next version of sqlite (use VERSION=x.y.z)"
  task :update_sqlite do
    require 'uri'
    require 'net/http'
    require 'zip'

    parts = ENV['VERSION'].split(".")
    next_version = [ parts.shift.to_s ]
    parts.each do |p|
      next_version << "#{"%02d" % p }"
    end
    next_version << "00" if next_version.size == 3

    next_version = next_version.join('')

    raise "VERSION env variable must be set" unless next_version
    url = ::URI.parse("http://sqlite.org/sqlite-amalgamation-#{next_version}.zip")
    puts "downloading #{url.to_s} ..."
    file = "tmp/#{File.basename( url.path ) }"
    FileUtils.mkdir "tmp" unless File.directory?( "tmp" )
    File.open( file, "wb+") do |f|
      res = Net::HTTP.get_response( url )
      f.write( res.body )
    end

    puts "extracting..."
    upstream_files = %w[ sqlite3.h sqlite3.c sqlite3ext.h ]
    Zip::ZipInputStream.open( file ) do |io|
      loop do
        entry = io.get_next_entry
        break unless entry
        bname = File.basename( entry.name )
        if upstream_files.include?( bname ) then
          dest_file = File.join( "ext", "amalgalite", "c", bname )
          puts "updating #{dest_file}"
          entry.extract( dest_file ) { true }
        end
      end
    end
  end
end
