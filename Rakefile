require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :default => :spec

desc "Clones the Test Repository"
task :repo do
  repos_dir = File.expand_path('./repos')
  FileUtils.cd(repos_dir) do
    puts `git clone git://github.com/atmos/hancock-client.git test`
  end
end

desc "Runs the RSpec Test Suite"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern    = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--color']
end
