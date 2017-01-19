# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grom/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'grom'
  spec.version     = Grom::VERSION
  spec.authors     = ['Rebecca Appleyard', 'Giuseppe De Santis', 'Matt Rayner']
  spec.email       = ['rklappleyard@gmail.com', 'giusdesan@gmail.com', 'mattrayner1@gmail.com']
  spec.homepage    = 'https://github.com/ukparliament/grom'
  spec.summary     = 'Grom is a Graph Object Mapper'
  spec.description = 'Grom is a Graph Object Mapper'
  spec.license     = 'Open Parliament License'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rdf'

  # the below are test dependencies
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'simplecov'
end
