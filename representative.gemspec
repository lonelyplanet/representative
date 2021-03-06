# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'representative/version'

Gem::Specification.new do |gem|
  gem.name = 'representative'
  gem.summary = 'Builds XML and JSON representations of your Ruby objects'
  gem.homepage = 'http://github.com/mdub/representative'
  gem.authors = ['Mike Williams']
  gem.email = 'mdub@dogbiscuit.org'

  gem.required_ruby_version = '>= 2.5'

  gem.version = Representative::VERSION.dup
  gem.platform = Gem::Platform::RUBY

  gem.add_development_dependency('rspec', '~> 3.9')
  gem.add_development_dependency('rubocop')
  gem.add_runtime_dependency('activesupport')
  gem.add_runtime_dependency('builder', '>= 2.1.2')
  gem.add_runtime_dependency('nokogiri', '>= 1.10')

  gem.require_path = 'lib'
  gem.files = Dir['lib/**/*', 'examples/**/*', 'README.markdown', 'LICENSE']
  gem.test_files = Dir['spec/**/*', 'Rakefile']
end
