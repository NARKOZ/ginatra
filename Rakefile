require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc "Clone test repository"
task :clone_repo do
  repos_dir = File.expand_path('./repos')
  FileUtils.cd(repos_dir) do
    puts `git clone git://github.com/atmos/hancock-client.git test`
  end unless Dir.exists?("#{repos_dir}/test")
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern    = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--color']
end

task default: ['clone_repo', 'spec']
