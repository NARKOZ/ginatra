require 'rspec'
require 'ginatra'
require 'sinatra'
require 'rack/test'

set :environment, :test

def app
  Ginatra::App
end

def current_path
  File.expand_path File.dirname(__FILE__)
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Ginatra::Helpers
end
