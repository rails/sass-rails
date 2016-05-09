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

  s.add_dependency 'railties',        '>= 4.0.0', '< 5.1'
  s.add_dependency 'sass',            '~> 3.4'
  s.add_dependency 'sprockets-rails', '< 4.0'
  s.add_dependency 'sprockets',       '~> 4.x'

  s.add_development_dependency 'sqlite3'

  s.files         = Dir["MIT-LICENSE", "README.md", "lib/**/*"]
  s.require_paths = ["lib"]
end
