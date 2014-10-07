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

  s.rubyforge_project = "sass-rails"

  s.add_dependency 'sass',            '~> 3.2'
  s.add_dependency 'railties',        '>= 4.0.0', '< 5.0'
  s.add_dependency 'sprockets-rails', '>= 2.0', '< 4.0'
  s.add_dependency 'sprockets',       '~> 2.12'

  s.require_paths = ["lib"]
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
end
