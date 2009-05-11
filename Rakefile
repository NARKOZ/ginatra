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

task :default => [:current]


