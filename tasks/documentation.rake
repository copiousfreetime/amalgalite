require 'tasks/config'

#-----------------------------------------------------------------------
# Documentation
#-----------------------------------------------------------------------

if rdoc_config = Configuration.for_if_exist?('rdoc') then

  namespace :doc do

    require 'rdoc'
    require 'rake/rdoctask'

    # generating documentation locally
    Rake::RDocTask.new do |rdoc|
      rdoc.rdoc_dir   = rdoc_config.output_dir
      rdoc.options    = rdoc_config.options 
      rdoc.rdoc_files = rdoc_config.files
      rdoc.title      = rdoc_config.title
      rdoc.main       = rdoc_config.main_page
    end

    if rubyforge_config = Configuration.for_if_exist?('rubyforge') then
      desc "Deploy the RDoc documentation to ENV['RDOC_DEPLOY']"
      task :deploy => :rerdoc do
        if ENV['RDOC_DEPLOY'] then
          sh "rsync -zav --delete #{rdoc_config.output_dir}/ #{ENV['RDOC_DEPLOY']}"
        else
          puts "To Deploy RDOC set the RDOC_DEPLOY environment variable"
        end
      end 
    end 

  end 
end

