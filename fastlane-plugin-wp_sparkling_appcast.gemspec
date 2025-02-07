lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/wp_sparkling_appcast/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-wp_sparkling_appcast'
  spec.version       = Fastlane::WpSparklingAppcast::VERSION
  spec.author        = 'Usiel Riedl'
  spec.email         = 'usiel.riedl@gmail.com'

  spec.summary       = 'This plugin helps you distribute your builds using WordPress\'s Sparkling Appcast plugin (Sparkle appcast.xml)'
  spec.homepage      = "https://github.com/Usiel/fastlane-plugin-wp_sparkling_appcast"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.7.0'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_dependency('rubyzip', '>= 2.3.0')
  spec.add_dependency('plist', '>= 3.6.0')

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'simplecov'
end
