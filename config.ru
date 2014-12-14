require 'ginatra'
require 'sprockets'

map '/assets' do
  environment = Sprockets::Environment.new
  root_path   = File.dirname __FILE__
  environment.append_path "#{root_path}/public/js"
  environment.append_path "#{root_path}/public/css"
  run environment
end

if Ginatra.config.git_clone_enabled?
  require 'mkmf'
  require 'git/webby'

  # Make the MakeMakefile logger write file output to null
  module MakeMakefile::Logging; @logfile = File::NULL; end

  git_executable = find_executable 'git'
  raise 'Git executable not found in PATH' if git_executable.nil?
  root_path = File.dirname __FILE__

  Git::Webby::HttpBackend.configure do |server|
    server.project_root = "#{root_path}/repos"
    server.git_path     = git_executable
    server.get_any_file = true
    server.upload_pack  = false
    server.receive_pack = false
    server.authenticate = false
  end

  run Rack::Cascade.new [Git::Webby::HttpBackend, Ginatra::App]
else
  map '/' do
    run Ginatra::App
  end
end
