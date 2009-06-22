require 'rubygems'
require 'cucumber/rake/task'
require 'spec/rake/spectask'

current_path = File.expand_path(File.dirname(__FILE__))
require "#{current_path}/lib/ginatra"

task :default => ['rake:spec', 'rake:features']

desc "Adds a Git Repository to Ginatra. Usage: `rake add repo='<git-repo-url>' [name='<name-in-ginatra>']`"
task "add" do |t|
  raise ArgumentError, "FATAL: You Must Specify a Git Repository to Clone" if ENV['repo'].empty?
  FileUtils.cd(repo_dir) do
    puts %x(git clone --bare #{ENV['repo']} #{(ENV['name'] + ".git") unless ENV['name'].empty?})
  end
end

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
    FileUtils.cd(repo_dir) do
      puts `git clone --bare git://github.com/atmos/hancock-client.git test.git`
    end
  end

  desc "Installs the Required Gems"
  task :gems do |t|
    gems = %w(grit kematzy-sinatra-cache)
    puts %x(gem install #{gems.join(" ")})
  end

  desc "Installs the Test Gems"
  task :test do |t|
    gems = %w(rspec webrat rack-test cucumber)
    puts %x(gem install #{gems.join(" ")})
  end

end

namespace :test do

  task :spec => ['rake:spec'] do
    puts ""
    puts "DEPRECIATION WARNING: `rake test:spec` has been replaced with `rake spec` -- I'm making your life easier"
    puts ""
  end

  task :features => ['rake:features'] do
    puts ""
    puts "DEPRECIATION WARNING: `rake test:features` has been replaced with `rake features` -- I'm making your life easier"
    puts ""
  end

end

def repo_dir
  if Ginatra::App.git_dir
    File.expand_path( Ginatra::App.git_dir )
  elsif Ginatra::App.git_dirs
    a = Dir.glob(Ginatra::App.git_dirs.first).first
    if Dir.entries(a).include?"refs"
      a = File.dirname(a)
    else
      a
    end
    File.expand_path( a )
  else
    raise ArgumentError, "You need to set `git_dir` or `git_dirs` for this rake task to work"
  end
end
