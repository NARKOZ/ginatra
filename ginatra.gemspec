lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ginatra/version'

Gem::Specification.new do |gem|
  gem.name          = "ginatra"
  gem.version       = Ginatra::VERSION
  gem.summary       = "A Gitweb Clone in Sinatra and Grit"
  gem.description   = "Host your own git repository browser through the power of Sinatra and Grit"
  gem.email         = "sam@lenary.co.uk"
  gem.homepage      = "http://lenary.co.uk/ginatra"
  gem.authors       = ["Sam Elliott", "Ryan Bigg"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'sinatra', '~> 1.3.3'
  gem.add_dependency 'grit',    '~> 2.5.0'
  gem.add_dependency 'vegas',   '~> 0.1.8'
  gem.add_dependency 'builder', '~> 3.1.4'
  gem.add_dependency 'erubis',  '~> 2.7.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webrat'
  gem.add_development_dependency 'rack-test'
end
