$:.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")

require "ginatra"

map '/' do
  run Ginatra::App
end
