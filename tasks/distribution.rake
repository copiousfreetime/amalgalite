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

    desc "reinstall gem"
    task :reinstall => [:uninstall, :repackage, :install]

    desc "package the windows gem"
    task :package_win => "ext:build_win" do
      cp "ext/amalgalite3.so", "lib", :verbose => true
      Gem::Builder.new( Amalgalite::GEM_SPEC_WIN ).build
      mv Dir["*.gem"].first, "pkg"
    end

    desc "distribute copiously"
    task :copious => [:package, :package_win] do
        gems = Amalgalite::SPECS.collect { |s| "#{s.full_name}.gem" }
        Rake::SshFilePublisher.new('jeremy@copiousfreetime.org',
                               '/var/www/vhosts/www.copiousfreetime.org/htdocs/gems/gems',
                               'pkg', *gems).upload
        sh "ssh jeremy@copiousfreetime.org rake -f /var/www/vhosts/www.copiousfreetime.org/htdocs/gems/Rakefile"
    end
 end
end
