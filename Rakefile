require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc "Clone test repository"
task :clone_repo do
  repos_dir = File.expand_path('./repos')
  FileUtils.cd(repos_dir) do
    puts `git clone git://github.com/atmos/hancock-client.git test`
  end
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern    = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--color']
end

namespace :assets do
  desc "Build JavaScript files"
  task :js do
    require 'sprockets'

    environment = Sprockets::Environment.new
    environment.append_path('public/js')

    File.open('public/main.js', 'w+') do |f|
      f.write environment['application.js'].to_s
    end
  end

  desc "Build CSS files"
  task :css do
    require 'sprockets'

    environment = Sprockets::Environment.new
    environment.append_path('public/css')

    File.open('public/main.css', 'w+') do |f|
      f.write environment['application.css'].to_s
    end
  end
end

task :default => :spec
task :travis  => ['clone_repo', 'spec']
task :assets  => ['assets:js', 'assets:css']
