
require 'bundler'
Bundler.setup(:default, :test)
require 'rspec'
require "ginatra"
require 'webrat'
require 'rack/test'

Webrat.configure do |config|
  config.mode = :rack
end

current_path = File.expand_path(File.dirname(__FILE__))

Ginatra::App.set :environment, :test
Ginatra::Config[:git_dirs] = ["#{current_path}/../repos/*"]

RSpec.configure do |config|
  def app
    Ginatra::App
  end

  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)
end

