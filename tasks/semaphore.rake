require 'yaml'
require 'json'
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

  # the artifact may be stored as the bare basename or under pkg/ depending on
  # how it was pushed, so try both
  def artifact_signed_url(basename)
    candidates = [basename, File.join("pkg", basename)]
    candidates.each do |path|
      query = URI.encode_www_form(scope: "projects", scope_id: project_id,
                                  path: path, method: "GET")
      begin
        body = URI.open("#{semaphore_api_endpoint}/artifacts/signed_url?#{query}",
                        "Authorization" => "Token #{auth_token}") { |f| f.read }
        url = JSON.parse(body).dig("items", 0, "url")
        return url if url
      rescue OpenURI::HTTPError => e
        warn "signed_url for #{path}: #{e.message}"
      end
    end
    abort "no signed url found for #{basename}"
  end

  # list the project artifacts at the root and under pkg/, the two places the
  # gems may have been stored
  def remote_artifacts
    ["", "pkg"].flat_map do |path|
      params = { scope: "projects", scope_id: project_id }
      params[:path] = path unless path.empty?
      query = URI.encode_www_form(params)
      begin
        body = URI.open("#{semaphore_api_endpoint}/artifacts?#{query}",
                        "Authorization" => "Token #{auth_token}") { |f| f.read }
        JSON.parse(body).fetch("artifacts", [])
      rescue OpenURI::HTTPError => e
        warn "list #{path.empty? ? '/' : path}: #{e.message}"
        []
      end
    end
  end

  def api_get(path)
    body = URI.open("#{semaphore_api_endpoint}/#{path}",
                    "Authorization" => "Token #{auth_token}") { |f| f.read }
    JSON.parse(body)
  rescue OpenURI::HTTPError => e
    warn "GET #{path}: #{e.message}"
    {}
  end

  desc "List project members, their roles and the permissions of those roles"
  task :permissions do
    # there is no "who am I" endpoint, so show every project member
    roles = Hash.new { |h, id| h[id] = api_get("roles/#{id}") }
    api_get("projects/#{project_id}/members").fetch("members", []).each do |m|
      puts "#{m['name']} (#{m['subject_type']})"
      m.fetch("roles", []).each do |r|
        puts "  #{r['role_name']} [#{r['source']}]"
        puts roles[r["role_id"]].fetch("permissions", []).sort.map { |p| "    #{p}" }
      end
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
      puts "Expected:"
      puts artifacts.map { |a| "  #{a}" }

      puts "Remote:"
      remote_artifacts.each do |a|
        size = a["is_directory"] ? "dir" : "#{a['size']} bytes"
        puts "  #{a['path']} (#{size})"
      end
    end

    desc "Download artifacts"
    task :download do
      artifacts.each do |basename|
        dest = File.join("pkg", basename)
        url  = artifact_signed_url(basename)
        puts "downloading #{basename} => #{dest}"
        # the signed url carries its own auth, do not send the api token
        URI.open(url) do |f|
          File.open(dest, "wb") do |out|
            out.write(f.read)
          end
        end
      end
    end
  end
end
