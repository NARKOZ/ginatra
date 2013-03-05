lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ginatra/version'

Gem::Specification.new do |gem|
  gem.name          = "ginatra"
  gem.version       = Ginatra::VERSION
  gem.summary       = "A Gitweb Clone in Sinatra and Grit"
  gem.description   = "Host your own git repository browser through the power of Sinatra and Grit"
  gem.email         = ["mail@narkoz.me"]
  gem.authors       = ["Nihad Abbasov", "Sam Elliott", "Ryan Bigg"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'sinatra', '~> 1.3.3'
  gem.add_dependency 'grit',    '~> 2.5.0'
  gem.add_dependency 'vegas',   '~> 0.1.8'
  gem.add_dependency 'builder', '~> 3.1.4'
  gem.add_dependency 'rouge', '~> 0.2.15'
  gem.add_dependency 'sprockets', '~> 2.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'better_errors'
  gem.add_development_dependency 'binding_of_caller'
end
