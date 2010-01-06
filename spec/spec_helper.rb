require 'rubygems'

#gem 'rspec'
require 'spec'

$:.unshift File.expand_path("#{File.dirname(__FILE__)}/../lib")
require "ginatra"

#gem 'webrat', '>=0.4.4'
begin
  # When using webrat 0.6.0, there is no webrat/sinatra.rb file.
  # Looking at the gem's code, it looks like it autoloads the sinatra adapter at webrat/adapters/sinatra.rb.
  # So requiring just 'webrat' will also load the sinatra adapater, which is done in the rescue clause.
  require 'webrat/sinatra'
rescue LoadError
  STDERR.puts "WARNING: could not load webrat/sinatra: #{__FILE__}:#{__LINE__}"
  require 'webrat'
end

#gem 'rack-test', '>=0.3.0'
require 'rack/test'

Webrat.configure do |config|
  config.mode = :sinatra
end

current_path = File.expand_path(File.dirname(__FILE__))

Ginatra::App.set :environment, :test
Ginatra::Config[:git_dirs] = ["#{current_path}/../repos/*"]

Spec::Runner.configure do |config|
  def app
    Ginatra::App
  end

  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)
end

