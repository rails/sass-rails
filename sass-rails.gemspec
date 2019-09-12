# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sass/rails/version"

Gem::Specification.new do |s|
  s.name        = "sass-rails"
  s.version     = Sass::Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["wycats", "chriseppstein"]
  s.email       = ["wycats@gmail.com", "chris@eppsteins.net"]
  s.homepage    = "https://github.com/rails/sass-rails"
  s.summary     = %q{Sass adapter for the Rails asset pipeline.}
  s.description = %q{Sass adapter for the Rails asset pipeline.}
  s.license     = %q{MIT}

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/rails/sass-rails/issues",
    "changelog_uri"     => "https://github.com/rails/sass-rails/releases/tag/v#{s.version}",
    "documentation_uri" => "https://www.rubydoc.info/gems/sass-rails/#{s.version}",
    "source_code_uri"   => "https://github.com/rails/sass-rails/tree/v#{s.version}"
  }

  s.add_dependency 'sassc-rails', '~> 2.1', '>= 2.1.1'

  s.files         = Dir["MIT-LICENSE", "README.md", "lib/**/*"]
  s.require_paths = ["lib"]
end
