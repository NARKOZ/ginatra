# Sinatra
app_file = File.join(File.dirname(__FILE__), *%w[.. .. ginatra.rb])
require app_file
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file

# RSpec matchers
require 'spec/expectations'

# Webrat
require 'webrat'
Webrat.configure do |config|
  config.mode = :sinatra
end

require "#{File.dirname(__FILE__)}/paths.rb"

World do
  include NavigationHelpers
  session = Webrat::SinatraSession.new
  session.extend(Webrat::Matchers)
  session.extend(Webrat::HaveTagMatcher)
  session
end

