Gem::Specification.new do |s|
  s.name = "ginatra"
  s.version = "3.0.0"
  s.summary = "A Gitweb Clone in Sinatra and Grit"
  s.description = "Host your own git repository browser through the power of Sinatra and Grit"
  s.email = "sam@lenary.co.uk"
  s.homepage = "http://lenary.co.uk/ginatra"
  s.authors = ["Sam Elliott", "Ryan Bigg"]
  s.add_dependency('bundler', '~> 1.0.15')
  s.add_dependency('sinatra', '~> 1.2.6')
  s.add_dependency('grit', '~> 2.4.1')
  s.add_dependency('vegas', '~> 0.1.8')
  s.add_dependency('builder', '~> 3.0.0')
  s.add_dependency('erubis', '~> 2.7.0')


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec`.split("\n")
  s.executables   = `git ls-files -- bin`.split("\n").map {|f| File.basename(f) }
  s.require_paths = ["lib"]
end
