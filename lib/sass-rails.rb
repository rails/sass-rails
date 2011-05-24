module Sass
  class CssCompressor
    def compress(css)
      Sass::Engine.new(css,
                       :syntax => :scss,
                       :cache => false,
                       :read_cache => false,
                       :style => :compressed).render
    end
  end

  class Railtie < ::Rails::Railtie
    config.sass = ActiveSupport::OrderedOptions.new
    config.sass.syntax = :scss

    initializer :setup_sass do |app|
      config.app_generators.stylesheet_engine app.config.sass.syntax
    end

    initializer :setup_compression do |app|
      if app.config.assets.compress
        app.config.assets.css_compressor = CssCompressor.new
      end
    end
  end
end

