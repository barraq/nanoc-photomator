# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib/', __FILE__))
require 'nanoc/photomator/version'

Gem::Specification.new do |s|
  s.name = 'nanoc-photomator'
  s.version = Nanoc::Photomator::VERSION
  s.homepage = 'https://github.com/barraq/nanoc-photomator'
  s.summary = 'Photo automation tools for Nanoc'
  s.description = 'Provides a set of commands, filters, helpers and user interfaces for working with photos and photosets in Nanoc'

  s.author = 'Rémi Barraquand'
  s.email = 'dev@remibarraquand.com'
  s.license = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.files = Dir['[A-Z]*'] +
      Dir['{lib,test}/**/*'] +
      ['nanoc-photomator.gemspec']
  s.require_paths = ['lib']

  s.rdoc_options = ['--main', 'README.md']
  s.extra_rdoc_files = ['LICENSE', 'README.md']

  # Qt bindings (for GUI)
  s.add_runtime_dependency('qtbindings', '~> 4.6')
  s.add_runtime_dependency('mini_magick', '~> 3.7')

  # For Nanoc 4.x
  #s.add_runtime_dependency('nanoc-core')
  #s.add_runtime_dependency('nanoc-cli')

 # For Nanoc 3.x
  s.add_runtime_dependency('nanoc', '>= 3.6.7', '< 4.0.0')

  # Autoloading
  s.add_development_dependency('bundler', '~> 1.5')
end
