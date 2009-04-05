require 'tasks/config'
require 'pathname'
require 'zlib'
require 'archive/tar/minitar'

#-----------------------------------------------------------------------
# Extensions
#-----------------------------------------------------------------------

if ext_config = Configuration.for_if_exist?('extension') then
  namespace :ext do  
    def current_sqlite_version
      ext = Configuration.for('extension').configs.first
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
    task :build do
      ext_config.configs.each do |extension|
        path  = Pathname.new(extension)
        parts = path.split
        conf  = parts.last
        Dir.chdir(path.dirname) do |d| 
          ruby conf.to_s
          sh "make"
        end
      end
    end

    desc "Build the extensions for windows"
    task :build_win => :clobber do
      ext_config.configs.each do |extension|
        path = Pathname.new( extension )
        parts = path.split
        conf = parts.last
        mingw_rbconfig = path.dirname.parent.realpath + "rbconfig-mingw.rb"
        Dir.chdir( path.dirname ) do |d|
          cp mingw_rbconfig, "rbconfig.rb"
          sh "ruby -I. extconf.rb"
          sh "make"
          rm_f "rbconfig.rb"
        end
      end
    end

    desc "Build the extension for ruby1.9"
    task :build19 => :clobber do
      ext_config.configs.each do |extension|
        path = Pathname.new( extension )
        parts = path.split
        conf = parts.last
        Dir.chdir( path.dirname ) do |d|
          sh "ruby1.9 -I. extconf.rb"
          sh "make"
        end
 
      end
    end

    task :clean do
      ext_config.configs.each do |extension|
        path  = Pathname.new(extension)
        parts = path.split
        conf  = parts.last
        Dir.chdir(path.dirname) do |d| 
          #sh "rake clean"
          sh "make clean"
          rm_f "rbconfig.rb"
        end
      end
    end

    task :clobber do
      ext_config.configs.each do |extension|
        path  = Pathname.new(extension)
        parts = path.split
        conf  = parts.last
        Dir.chdir(path.dirname) do |d| 
          #sh "rake clobber"
          if File.exist?( "Makefile") then
            sh "make distclean"
          end
          rm_f "rbconfig.rb"
        end
      end
    end

    desc "Download and integrate the next version of sqlite (use VERSION=x.y.z)"
    task :update_sqlite do
      next_version = ENV['VERSION']
      raise "VERSION env variable must be set" unless next_version
      puts "downloading ..."
      url = URI.parse("http://sqlite.org/sqlite-amalgamation-#{next_version}.tar.gz")
      file = "tmp/#{File.basename( url.path ) }"
      FileUtils.mkdir "tmp" unless File.directory?( "tmp" )
      File.open( file, "wb+") do |f|
        res = Net::HTTP.get_response( url )
        f.write( res.body )
      end

      puts "extracting..."
      upstream_files = %w[ sqlite3.h sqlite3.c sqlite3ext.h ]
      Zlib::GzipReader.open( file ) do |tgz|
        Archive::Tar::Minitar::Reader.open( tgz ) do |tar|
          tar.each_entry do |entry|
            bname = File.basename( entry.full_name )
            if upstream_files.include?( bname ) then
              dest_file = File.join( "ext", bname )
              puts "updating #{ dest_file }"
              File.open( dest_file, "wb" ) do |df|
                while bytes = entry.read do
                  df.write bytes
                end
              end
            end
          end
        end
      end
    end
  end
end
