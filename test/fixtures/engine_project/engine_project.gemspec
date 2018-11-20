$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "engine_project/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "engine_project"
  s.version     = EngineProject::VERSION
  s.authors     = ["Your name"]
  s.email       = ["Your email"]
  s.summary     = "Summary of EngineProject."
  s.description = "Description of EngineProject."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0.0.beta"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
