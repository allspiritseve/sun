# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sun/version'

Gem::Specification.new do |spec|
  spec.name = 'sun'
  spec.version = Sun::VERSION
  spec.authors = ['Cory Kaufman-Schofield']
  spec.email = ['cory@corykaufman.com']

  spec.summary = 'Calculate sunrise and sunset times'
  spec.homepage = 'https://github.com/allspiritseve/sun'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
end
