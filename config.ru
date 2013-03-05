require 'ginatra'
require 'sprockets'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'public/js'
  environment.append_path 'public/css'
  run environment
end

map '/' do
  run Ginatra::App
end
