current_path = File.expand_path(File.dirname(__FILE__))

require "#{current_path}/lib/ginatra"

map '/' do
  run Ginatra::App
end
