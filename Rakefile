require 'rubygems'
require 'cucumber/rake/task'
require 'spec/rake/spectask'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty"
end

Cucumber::Rake::Task.new(:current) do |c|
  c.cucumber_opts = "--format pretty -t current"
end

Spec::Rake::SpecTask.new(:spec) do |r|
  r.spec_files = FileList['spec/*_spec.rb']
  r.spec_opts = ['--color']
end


namespace :submodules do
  task :init do
    puts "Submodules INIT"
    `git submodule init 2>&1`
  end
  task :update do
    puts "Submodules UPDATE"
    puts `git submodule update 2>&1`
  end
end


