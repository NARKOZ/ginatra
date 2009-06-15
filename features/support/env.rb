current_path = File.expand_path(File.dirname(__FILE__))
require "#{current_path}/../../spec/spec_helper"

World do
  def app
    Ginatra::App
  end
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
end

