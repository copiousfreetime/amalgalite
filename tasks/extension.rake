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

    def build_win( version = "1.8.6" )
      ext_config = Configuration.for("extension")
      rbconfig = ext_config.cross_rbconfig["rbconfig-#{version}"]
      raise ArgumentError, "No cross compiler for version #{version}, we have #{ext_config.cross_rbconfig.keys.join(",")}" unless rbconfig
      ruby_exe = if version =~ /1\.8/ then
                   "ruby"
                 else
                   "ruby1.9"
                 end
      Amalgalite::GEM_SPEC.extensions.each do |extension|
        path = Pathname.new(extension)
        parts = path.split
        conf = parts.last
        Dir.chdir(path.dirname) do |d| 
          cp "#{rbconfig}", "rbconfig.rb"
          sh "#{ruby_exe} -I. extconf.rb"
          sh "make"
        end
      end
    end

    win_builds = []
    ext_config.cross_rbconfig.keys.each do |v|
      s = v.split("-").last
      desc "Build the extension for windows version #{s}"
      win_bname = "build_win-#{s}"
      win_builds << win_bname
      task win_bname => :clean do
        build_win( s )
      end
    end

    task :clean do
      ext_config.configs.each do |extension|
        path  = Pathname.new(extension)
        parts = path.split
        conf  = parts.last
        Dir.chdir(path.dirname) do |d| 
          if File.exist?( "Makfeile" ) then
            sh "make clean"
          end
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
              dest_file = File.join( "ext", "amalgalite", bname )
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
