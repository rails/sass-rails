module Sass::Rails
  class Railtie < ::Rails::Railtie
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

    end

    initializer :setup_compression do |app|
      if app.config.assets.compress
        # Use sass's css_compressor
        app.config.assets.css_compressor = CssCompressor.new
      end
    end
  end
end
