# frozen_string_literal: true

require_relative 'lib/typochecker/version'

Gem::Specification.new do |spec|
  spec.name = 'typochecker'
  spec.version = Typochecker::VERSION
  spec.authors = ['noppe']
  spec.summary = 'Levenshtein distance based English typo checker'
  spec.description = 'A small Ruby command-line typo checker that suggests English words using Levenshtein distance.'
  spec.homepage = 'https://github.com/hiroyan/typochecker'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6'
  spec.metadata = {
    'source_code_uri' => spec.homepage
  }

  spec.files = Dir[
    'README.md',
    'mit.txt',
    'words.txt',
    'keyword.txt',
    'lib/**/*.rb',
    'exe/*'
  ]
  spec.bindir = 'exe'
  spec.executables = ['typochecker']
  spec.require_paths = ['lib']
end
