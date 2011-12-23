require 'tilt'
require 'sprockets'

module Sass::Rails

  class Resolver

    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def resolve(path, content_type = :self)
      options = {}
      options[:content_type] = content_type unless content_type.nil?
      context.resolve(path, options)
    rescue Sprockets::FileNotFound, Sprockets::ContentTypeMismatch
      nil
    end

    def public_path(path, scope)
      context.asset_paths.compute_public_path(path, ::Rails.application.config.assets.prefix)
    end

    def process(path)
      context.environment[path].to_s
    end

    def image_path(img)
      context.image_path(img)
    end

    def video_path(video)
      context.video_path(video)
    end

    def audio_path(audio)
      context.audio_path(audio)
    end

    def javascript_path(javascript)
      context.javascript_path(javascript)
    end

    def stylesheet_path(stylesheet)
      context.stylesheet_path(stylesheet)
    end
  end

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
        :load_paths => load_paths,
        :custom => {
          :resolver => Resolver.new(scope)
        }
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
