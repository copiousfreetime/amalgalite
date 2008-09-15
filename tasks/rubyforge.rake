require 'tasks/config'    

#-----------------------------------------------------------------------
# Rubyforge additions to the task library
#-----------------------------------------------------------------------
if rf_conf = Configuration.for_if_exist?("rubyforge") then

  abort("rubyforge gem not installed 'gem install rubyforge'") unless Utils.try_require('rubyforge')
  
  proj_conf = Configuration.for('project')

  namespace :dist do
    desc "Release files to rubyforge"
    task :rubyforge => [:clean, :package] do

      rubyforge = RubyForge.new

      config = {}
      config["release_notes"]     = proj_conf.description
      config["release_changes"]   = Utils.release_notes_from(proj_conf.history)[Amalgalite::VERSION]
      config["Prefomatted"]       = true

      rubyforge.configure config

      # make sure this release doesn't already exist
      releases = rubyforge.autoconfig['release_ids']
      if releases.has_key?(Amalgalite::GEM_SPEC.name) and releases[Amalgalite::GEM_SPEC.name][Amalgalite::VERSION] then
        abort("Release #{Amalgalite::VERSION} already exists! Unable to release.")
      end

      puts "Uploading to rubyforge..."
      files = FileList[File.join("pkg","#{Amalgalite::GEM_SPEC.name}-#{Amalgalite::VERSION}*.*")].to_a
      rubyforge.login
      rubyforge.add_release(Amalgalite::GEM_SPEC.rubyforge_project, Amalgalite::GEM_SPEC.name, Amalgalite::VERSION, *files)
      puts "done."
    end
  end

  namespace :announce do
    desc "Post news of #{proj_conf.name} to #{rf_conf.project} on rubyforge"
    task :rubyforge do
      info = Utils.announcement

      puts "Subject : #{info[:subject]}"
      msg = "#{info[:title]}\n\n#{info[:urls]}\n\n#{info[:release_notes]}"
      puts msg

      rubyforge = RubyForge.new
      rubyforge.configure
      rubyforge.login
      rubyforge.post_news(rf_conf.project, info[:subject], msg )
      puts "Posted to rubyforge"
    end

  end
end
