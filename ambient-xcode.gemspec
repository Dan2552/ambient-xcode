lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'ambient-xcode'
  gem.version       = '0.5.1'
  gem.authors       = ['Daniel Green']
  gem.email         = ['dan2552@gmail.com']
  gem.description   = %q{CLI for configuring Xcode projects from a Ruby file.}
  gem.summary       = %q{Define your envrionment settings all in one easy to read Ruby file, and re-apply it to your Xcode project to ensure settings are correct.}
  gem.homepage      = 'https://github.com/Dan2552/ambient'
  gem.license       = 'MIT'

  gem.add_dependency 'xcodeproj', '~> 1.1.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
