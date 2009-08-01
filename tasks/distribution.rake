require 'tasks/config'

#-------------------------------------------------------------------------------
# Distribution and Packaging
#-------------------------------------------------------------------------------
if pkg_config = Configuration.for_if_exist?("packaging") then

  require 'gemspec'
  require 'rake/gempackagetask'
  require 'rake/contrib/sshpublisher'

  namespace :dist do

    Rake::GemPackageTask.new(Amalgalite::GEM_SPEC) do |pkg|
      pkg.need_tar = pkg_config.formats.tgz
      pkg.need_zip = pkg_config.formats.zip
    end

    desc "Install as a gem"
    task :install => [:clobber, :package] do
      sh "sudo gem install --local pkg/#{Amalgalite::GEM_SPEC.full_name}.gem --no-rdoc --no-ri"
    end

    desc "Uninstall gem"
    task :uninstall do 
      sh "sudo gem uninstall -i #{Amalgalite::GEM_SPEC.name} -x"
    end

    desc "dump gemspec"
    task :gemspec do
      puts Amalgalite::GEM_SPEC.to_ruby
    end

    desc "dump gemspec for win"
    task :gemspec_win do
      puts Amalgalite::GEM_SPEC_WIN.to_ruby
    end

    desc "reinstall gem"
    task :reinstall => [:uninstall, :repackage, :install]

    desc "package up a windows gem"
    task :package_win => :clean do
      Configuration.for("extension").cross_rbconfig.keys.each do |rbconfig|
        v = rbconfig.split("-").last
        s = v.sub(/\.\d$/,'')
        sh "rake ext:build_win-#{v}"
        mkdir_p "lib/amalgalite/#{s}", :verbose => true
        cp "ext/amalgalite/amalgalite3.so", "lib/amalgalite/#{s}/", :verbose => true
      end

      Amalgalite::SPECS.each do |spec|
        next if spec.platform == "ruby"
        spec.files +=  FileList["lib/amalgalite/{1.8,1.9}/**.{dll,so}"]
        Gem::Builder.new( spec ).build 
        mkdir "pkg" unless File.directory?( 'pkg' )
        mv Dir["*.gem"].first, "pkg"
      end
    end

    task :clobber do
      rm_rf 'lib/amalgalite/1.8'
      rm_rf 'lib/amalgalite/1.9'
    end

    task :prep => [:clobber, :package, :package_win ]

    desc "distribute copiously"
    task :copious => :prep do
      gems = Amalgalite::SPECS.collect { |s| "#{s.full_name}.gem" }
      Rake::SshFilePublisher.new('jeremy@copiousfreetime.org',
                               '/var/www/vhosts/www.copiousfreetime.org/htdocs/gems/gems',
                               'pkg', *gems).upload
      sh "ssh jeremy@copiousfreetime.org rake -f /var/www/vhosts/www.copiousfreetime.org/htdocs/gems/Rakefile"
    end
  end
end
