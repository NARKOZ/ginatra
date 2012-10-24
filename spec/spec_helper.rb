require 'rspec'
require 'ginatra'
require 'sinatra'
require 'webrat'
require 'rack/test'

set :environment, :test

def app
  Ginatra::App
end

def current_path
  File.expand_path File.dirname(__FILE__)
end
Ginatra::Config[:git_dirs] = ["#{current_path}/../repos/*"]

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Webrat::Methods
  config.include Webrat::Matchers
end

Webrat.configure do |config|
  config.mode = :rack
end
