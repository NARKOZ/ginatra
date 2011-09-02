require "bundler"
Bundler.setup(:default, :development)
require 'rspec/core/rake_task'

task :default => ['rake:spec']

desc "Clones the Test Repository"
task :repo do |t|
  FileUtils.cd(File.join(File.dirname(__FILE__), "repos")) do
    puts `git clone git://github.com/atmos/hancock-client.git test`
  end
end

desc "Runs the RSpec Test Suite"
RSpec::Core::RakeTask.new(:spec) do |r|
  r.pattern = 'spec/*_spec.rb'
  r.rspec_opts = ['--color']
end

