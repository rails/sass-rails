# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'rails'
require "rails/test_help"
require 'sass/rails'
require 'sfl'
require 'mocha'

Rails.backtrace_cleaner.remove_silencers!

# Set locations of local gems in this hash.
# They will be added/replaced in the generated Gemfiles
# You should also set them in the local Gemfile
$gem_locations = {
  "sass-rails" => File.expand_path("../../", __FILE__)
}

# Uncomment this if you need to test against a local rails checkout
# $gem_locations["rails"] = "/Users/chris/Projects/rails"
# Uncomment this if you need to test against a local sass checkout
# $gem_locations["sass"] = "/Users/chris/Projects/sass"
# Uncomment this if you need to test against a local sprockets checkout
# $gem_locations["sprockets"] = "/Users/chris/Projects/sprockets"


# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }