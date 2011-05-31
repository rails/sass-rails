require 'tilt'
require 'sprockets'

module Sass::Rails
  class SassTemplate < Tilt::SassTemplate
    self.default_mime_type = 'text/css'

    def self.engine_initialized?
      defined?(::Sass::Engine)
    end

    def initialize_engine
      require_template_library 'sass'
    end

    def syntax
      :sass
    end

    def sass_options_from_rails(scope)
      scope.environment.context_class.sass_config
    end

    def sass_options(scope)
      importer = self.importer(scope)
      options = sass_options_from_rails(scope)
      load_paths = (options[:load_paths] || []).dup
      load_paths.unshift(importer)
      options.merge(
        :filename => eval_file,
        :line => line,
        :syntax => syntax,
        :importer => importer,
        :load_paths => load_paths
      )
    end

    def importer(scope)
      Sass::Rails::Importer.new(scope)
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      Sass::Engine.new(data, sass_options(scope)).render
    end
  end

  class ScssTemplate < SassTemplate
    self.default_mime_type = 'text/css'

    def syntax
      :scss
    end
  end
end

Sprockets::Engines #invoke autoloading
Sprockets.register_engine '.sass', Sass::Rails::SassTemplate
Sprockets.register_engine '.scss', Sass::Rails::ScssTemplate
