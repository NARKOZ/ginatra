require 'rubygems'
require 'sinatra'
require 'rack/test'
 
module RackTestMethods
  def app
    Sinatra::Application.new
  end
end
 
 
Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
  config.include RackTestMethods
end
 
require 'ginatra'

@app = Sinatra::Application

