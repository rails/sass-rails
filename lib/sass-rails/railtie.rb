module Sass::Rails
  class Railtie < ::Rails::Railtie
    config.sass = ActiveSupport::OrderedOptions.new
    config.sass.preferred_syntax = :scss

    initializer :setup_sass do |app|
      syntax     = app.config.sass.preferred_syntax.to_sym
      alt_syntax = syntax == :sass ? "scss" : "sass"

      app.config.generators.hide_namespace alt_syntax
      config.app_generators.stylesheet_engine syntax
    end

    initializer :setup_compression do |app|
      if app.config.assets.compress
        app.config.assets.css_compressor = CssCompressor.new
      end
    end
  end
end
