require 'sprockets/railtie'

module Sass::Rails
  class Railtie < ::Rails::Railtie
    module SassContext
      attr_accessor :sass_config
    end
    config.sass = ActiveSupport::OrderedOptions.new
    # Establish static configuration defaults
    # Emit scss files during stylesheet generation of scaffold
    config.sass.preferred_syntax = :scss
    # Use expanded output instead of the sass default of :nested
    config.sass.style            = :expanded
    # Write sass cache files to tmp/sass-cache for performance
    config.sass.cache            = true
    # Read sass cache files from tmp/sass-cache for performance
    config.sass.read_cache       = true
    # Display line comments above each selector as a debugging aid
    config.sass.line_comments    = true
    # Initialize the load paths to an empty array
    config.sass.load_paths       = []
    # Send Sass logs to Rails.logger
    config.sass.logger           = Sass::Rails::Logger.new

    config.before_initialize do |app|
      unless app.config.assets && app.config.assets.enabled
        raise "The sass-rails plugin requires the asset pipeline to be enabled."
      end

      require 'sass'
      Sprockets::Engines #force autoloading
      Sprockets.register_engine '.sass', Sass::Rails::SassTemplate
      Sprockets.register_engine '.scss', Sass::Rails::ScssTemplate
    end

    initializer :setup_sass do |app|
      # Only emit one kind of syntax because though we have registered two kinds of generators
      syntax     = app.config.sass.preferred_syntax.to_sym
      alt_syntax = syntax == :sass ? "scss" : "sass"
      app.config.generators.hide_namespace alt_syntax

      # Set the stylesheet engine to the preferred syntax
      config.app_generators.stylesheet_engine syntax

      # Set the sass cache location to tmp/sass-cache
      config.sass.cache_location   = File.join(Rails.root, "tmp/sass-cache")

      # Establish configuration defaults that are evironmental in nature
      if config.sass.full_exception.nil?
        # Display a stack trace in the css output when in development-like environments.
        config.sass.full_exception = app.config.consider_all_requests_local
      end

      # app.assets might be nil if asset pipeline is not enabled
      if app.assets
        app.assets.context_class.extend(SassContext)
        app.assets.context_class.sass_config = app.config.sass
      else
        $stderr.puts 'sass-rails now requires asset pipeline to be enabled. ' <<
          'Please put config.assets.enabled = true into your application.rb file.'
      end
    end

    initializer :setup_compression do |app|
      if app.config.assets.compress
        # Use sass's css_compressor
        app.config.assets.css_compressor = CssCompressor.new
      end
    end

    config.after_initialize do |app|
      Sass::logger = app.config.sass.logger
    end
  end
end
