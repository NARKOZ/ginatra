require "bundler"
Bundler.setup(:default)
require "ginatra"

map '/' do
  run Ginatra::App
end
