lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ginatra/version'

Gem::Specification.new do |gem|
  gem.name          = "ginatra"
  gem.version       = Ginatra::VERSION
  gem.summary       = "Web interface for git repositories"
  gem.description   = "Git repository viewer with a rocking good web interface"
  gem.homepage      = "https://github.com/narkoz/ginatra"
  gem.email         = ["mail@narkoz.me"]
  gem.authors       = ["Nihad Abbasov", "Sam Elliott", "Ryan Bigg"]

  gem.files         = `git ls-files`.split($/) - ['Gemfile.lock']
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9"

  gem.add_dependency 'sinatra',   '~> 1.4.5'
  gem.add_dependency 'rugged',    '~> 0.21.3'
  gem.add_dependency 'rouge',     '~> 1.7.7'
  gem.add_dependency 'sprockets', '~> 2.0'
  gem.add_dependency 'better_errors', '~> 1.1.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'sinatra-contrib'
  gem.add_development_dependency 'binding_of_caller'
end
