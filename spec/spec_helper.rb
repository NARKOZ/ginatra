ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'ginatra'
require 'rack/test'

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

Ginatra.config.git_dirs << "./repos/*" unless Ginatra.config.git_dirs.include?('./repos/*')
