# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sass/rails/version"

Gem::Specification.new do |s|
  s.name        = "sass-rails"
  s.version     = Sass::Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["wycats", "chriseppstein"]
  s.email       = ["wycats@gmail.com", "chris@eppsteins.net"]
  s.homepage    = ""
  s.summary     = %q{Sass adapter for the Rails asset pipeline.}
  s.description = %q{Sass adapter for the Rails asset pipeline.}

  s.rubyforge_project = "sass-rails"

  s.add_runtime_dependency 'sass',       '~> 3.1.10'
  s.add_runtime_dependency 'railties',   '~> 3.1.0'
  s.add_runtime_dependency 'actionpack', '~> 3.1.0'
  s.add_runtime_dependency 'tilt',       '~> 1.3.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
