require 'yaml'
require 'uri'
require 'open-uri'

namespace :semaphore do

  def semaphore_config
    config_file = File.join(ENV['HOME'], '.sem.yaml')
    if File.exist?(config_file)
      config = YAML.load_file(config_file)
      config.dig('contexts', 'copiousfreetime_semaphoreci_com')
    else
      nil
    end
  end

  def auth_token
    semaphore_config.dig('auth', 'token')
  end

  def semaphore_endpoint
    "https://#{semaphore_config['host']}"
  end

  def semaphore_api_endpoint
    "#{semaphore_endpoint}/api/v1alpha"
  end

  def project_meta
    @project_meta ||= URI.open("#{semaphore_api_endpoint}/projects/#{This.name}",
             "Authorization" => "Token #{auth_token}") do |f|
      JSON.parse(f.read)
    end
  end

  def project_id
    project_meta.dig('metadata', 'id')
  end

  def artifacts
    This.cross_platforms.map do |platform|
      name = Gem::NameTuple.new(This.name, This.version, platform)
      basename = "#{name.full_name}.gem"
      basename
    end
  end

  desc "Dump semaphore config"
  task :config do
    puts semaphore_config.to_yaml
  end

  desc "Dump semaphore project meta"
  task :meta do
    puts JSON.pretty_generate(project_meta)
  end

  namespace :artifacts do

    desc "List artifacts"
    task :list do
      puts artifacts
    end

    desc "Download artifacts"
    task :download do
      artifacts.each do |basename|
        url = "#{semaphore_endpoint}/projects/#{project_id}/artifacts/#{basename}"
        dest = File.join("pkg", basename)
        puts "downloading #{url} => #{dest}"
        URI.open(url, "Authorization" => "Token #{auth_token}") do |f|
          File.open(dest, "wb") do |out|
            out.write(f.read)
          end
        end
      end
    end
  end
end
