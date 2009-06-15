require 'rubygems'

gem 'rspec'
require 'spec'

current_path = File.expand_path(File.dirname(__FILE__))
require "#{current_path}/../lib/ginatra"

gem 'webrat', '~>0.4.4'
require 'webrat/sinatra'
gem 'rack-test', '~>0.3.0'
require 'rack/test'

Webrat.configure do |config|
  config.mode = :sinatra
end

Ginatra::App.set :environment, :test
 
Spec::Runner.configure do |config|
  def app
    Ginatra::App
  end
  
  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)
end 

