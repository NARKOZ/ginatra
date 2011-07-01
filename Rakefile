require "bundler"
Bundler.setup(:default, :development)
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

task :default => ['rake:spec', 'rake:features']


desc "Clones the Test Repository"
task :repo do |t|
  FileUtils.cd(File.join(File.dirname(__FILE__), "repos")) do
    puts `git clone git://github.com/atmos/hancock-client.git test`
  end
end

desc "Runs the Cucumber Feature Suite"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ["--format pretty", "features"]
end
namespace :features do
  desc "Runs the `@current` feature(s) or scenario(s)"
  Cucumber::Rake::Task.new(:current) do |c|
    c.cucumber_opts = ["--format pretty", "-t current", "features"]
  end
end

desc "Runs the RSpec Test Suite"
RSpec::Core::RakeTask.new(:spec) do |r|
  r.pattern = 'spec/*_spec.rb'
  r.rspec_opts = ['--color']
end
namespace :spec do
  desc "RSpec Test Suite with pretty output"
  RSpec::Core::RakeTask.new(:long) do |r|
    r.pattern = 'spec/*_spec.rb'
    r.rspec_opts = ['--color', '--format documentation']
  end
end

