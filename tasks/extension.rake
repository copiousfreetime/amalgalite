#-----------------------------------------------------------------------
# Extensions
#-----------------------------------------------------------------------
require 'pathname'
namespace :ext do
  def current_sqlite_version
    ext = Util.platform_gemspec.extensions.first
    path = Pathname.new( ext )
    h_path = path.dirname.realpath + "sqlite3.h"
    File.open( h_path ) do |f|
      f.each_line do |line|
        if line =~ /\A#define SQLITE_VERSION\s+/ then
          define ,constant ,value = line.split
          return value
        end
      end
    end
  end

  desc "Build the SQLite extension version #{current_sqlite_version}"
  task :build => :clean do
    with_each_extension do |extension|
      path  = Pathname.new(extension)
      parts = path.split
      conf  = parts.last
      Dir.chdir(path.dirname) do |d| 
        ruby conf.to_s
        sh "make"

        # install into requireable location so specs will run
        subdir = "amalgalite/#{RUBY_VERSION.sub(/\.\d$/,'')}"
        dest_dir = Amalgalite::Paths.lib_path( subdir )
        mkdir_p dest_dir, :verbose => true
        cp "amalgalite3.#{Config::CONFIG['DLEXT']}", dest_dir, :verbose => true
      end
    end
  end

  def with_each_extension
    Util.platform_gemspec.extensions.each do |ext|
      yield ext
    end
  end

  def myruby
    require 'rbconfig'
    x = File.join(
      RbConfig::CONFIG['bindir'],
      RbConfig::CONFIG['ruby_install_name']
    )
    #puts "myruby = #{x}"
    return x
  end

  # FIXME: building on windows is broken
  def build_win( version = "1.8.7" )
    ext_config = Util.platform_gemspec.extensions.first
    rbconfig = ext_config.cross_rbconfig["rbconfig-#{version}"]
    raise ArgumentError, "No cross compiler for version #{version}, we have #{ext_config.cross_rbconfig.keys.join(",")}" unless rbconfig
    with_each_extension do |extension|
      path = Pathname.new(extension)
      parts = path.split
      conf = parts.last
      rvm = File.expand_path( "~/.rvm/bin/rvm" )
      Dir.chdir(path.dirname) do |d| 
        if File.exist?( "Makefile" ) then
          sh "make clean distclean"
        end
        cp "#{rbconfig}", "rbconfig.rb"
        rubylib = ENV['RUBYLIB']
        ENV['RUBYLIB'] = "."
        sh %[ #{rvm} #{version} -S extconf.rb #{myruby} ]
        ENV['RUBYLIB'] = rubylib
        sh "make"
      end
    end
  end

  win_builds = []
  # ext_config.cross_rbconfig.keys.each do |v|
    # s = v.split("-").last
    # desc "Build the extension for windows version #{s}"
    # win_bname = "build_win-#{s}"
    # win_builds << win_bname
    # task win_bname => :clean do
      # build_win( s )
    # end
  # end

  task :clean do
    with_each_extension do |extension|
      path  = Pathname.new(extension)
      parts = path.split
      conf  = parts.last
      Dir.chdir(path.dirname) do |d| 
        if File.exist?( "Makefile" ) then
          sh "make clean"
        end
        rm_f "rbconfig.rb"
      end
    end
  end

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

    sqlite_h = File.join( *%w[ ext amalgalite sqlite3.h ] )
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

    Dir.glob("ext/amalgalite/amalgalite*.c").each do |am_file|
      IO.readlines( am_file ).each do |am_line|
        if md = am_line.match( /(sqlite3_[^(\s]+)\(/ ) then
                                 api_todo.delete( md.captures[0] )
        end
      end
    end

    puts "#{api_todo.keys.size} functions to still implement"
    puts api_todo.keys.sort.join("\n")
  end

  task :clobber do
    with_each_extension do |extension|
      path  = Pathname.new(extension)
      parts = path.split
      conf  = parts.last
      Dir.chdir(path.dirname) do |d| 
        if File.exist?( "Makefile") then
          sh "make distclean"
        end
        rm_f "rbconfig.rb"
      end
    end
  end

  desc "Download and integrate the next version of sqlite (use VERSION=x.y.z)"
  task :update_sqlite do
    require 'uri'
    require 'net/http'
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
          dest_file = File.join( "ext", "amalgalite", bname )
          puts "updating #{dest_file}"
          entry.extract( dest_file ) { true }
        end
      end
    end
  end
end
