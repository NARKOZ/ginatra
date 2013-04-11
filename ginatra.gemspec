lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ginatra/version'

Gem::Specification.new do |gem|
  gem.name          = "ginatra"
  gem.version       = Ginatra::VERSION
  gem.summary       = "A Gitweb Clone in Sinatra and Grit"
  gem.description   = "Host your own git repository browser through the power of Sinatra and Grit"
  gem.homepage      = "https://github.com/narkoz/ginatra"
  gem.email         = ["mail@narkoz.me"]
  gem.authors       = ["Nihad Abbasov", "Sam Elliott", "Ryan Bigg"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9"

  gem.add_dependency 'sinatra',   '~> 1.3.3'
  gem.add_dependency 'grit',      '~> 2.5.0'
  gem.add_dependency 'rouge',     '~> 0.3.2'
  gem.add_dependency 'sprockets', '~> 2.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'sinatra-contrib'
  gem.add_development_dependency 'better_errors'
  gem.add_development_dependency 'binding_of_caller'
end
