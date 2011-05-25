module Sass::Rails
  class Railtie < ::Rails::Railtie
    config.sass = ActiveSupport::OrderedOptions.new
    config.sass.syntax = :scss

    initializer :setup_sass do |app|
      syntax     = app.config.sass.syntax
      alt_syntax = syntax.to_s == "sass" ? "scss" : "sass"

      app.config.generators.hide_namespace alt_syntax
      config.app_generators.stylesheet_engine app.config.sass.syntax
    end

    initializer :setup_compression do |app|
      if app.config.assets.compress
        app.config.assets.css_compressor = CssCompressor.new
      end
    end
  end
end
