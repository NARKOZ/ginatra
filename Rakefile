require 'rubygems'
require 'cucumber/rake/task'
require 'spec/rake/spectask'

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")

require "ginatra"

task :default => ['rake:spec', 'rake:features']

desc "Runs the Cucumber Feature Suite"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty"
end

namespace :features do

  desc "Runs the `@current` feature(s) or scenario(s)"
  Cucumber::Rake::Task.new(:current) do |c|
    c.cucumber_opts = "--format pretty -t current"
  end

end

desc "Runs the RSpec Test Suite"
Spec::Rake::SpecTask.new(:spec) do |r|
  r.spec_files = FileList['spec/*_spec.rb']
  r.spec_opts = ['--color']
end

namespace :spec do

  desc "RSpec Test Suite with pretty output"
  Spec::Rake::SpecTask.new(:long) do |r|
    r.spec_files = FileList['spec/*_spec.rb']
    r.spec_opts = ['--color', '--format specdoc']
  end

  desc "RSpec Test Suite with html output"
  Spec::Rake::SpecTask.new(:html) do |r|
    r.spec_files = FileList['spec/*_spec.rb']
    r.spec_opts = ['--color', '--format html:spec/html_spec.html']
  end

end

namespace :setup do

  desc "Clones the Test Repository"
  task :repo do |t|
    FileUtils.cd(File.join(current_path, "repos")) do
      puts `git clone git://github.com/atmos/hancock-client.git test`
    end
  end

  desc "Installs the Required Gems"
  task :gems do |t|
    gems = %w(grit kematzy-sinatra-cache vegas)
    puts %x(gem install #{gems.join(" ")})
  end

  desc "Installs the Test Gems"
  task :test do |t|
    gems = %w(rspec webrat rack-test cucumber)
    puts %x(gem install #{gems.join(" ")})
  end

end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "ginatra"
    gemspec.summary = "A Gitweb Clone in Sinatra and Grit"
    gemspec.description = "Host your own git repository browser through the power of Sinatra and Grit"
    gemspec.email = "sam@lenary.co.uk"
    gemspec.homepage = "http://lenary.github.com/ginatra"
    gemspec.authors = ["Sam Elliott", "Ryan Bigg"]
    gemspec.add_dependency('sinatra', '>=0.9.4')
    gemspec.add_dependency('grit', '>=1.1.1')
    gemspec.add_dependency('coderay', '>=0.8.0')
    gemspec.files.include 'vendor/**/*'
    gemspec.version = Ginatra::VERSION
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

