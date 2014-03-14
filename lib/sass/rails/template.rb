require "sprockets/sass_template"

module Sass
  module Rails
    class SassTemplate < Sprockets::SassTemplate

      def evaluate(context, locals, &block)
        cache_store = Sprockets::SassCacheStore.new(context.environment)

        options = {
          :filename => eval_file,
          :line => line,
          :syntax => syntax,
          :cache_store => cache_store,
          :importer => SassImporter.new(context.pathname.to_s),
          :load_paths => context.environment.paths.map { |path| SassImporter.new(path.to_s) },
          :sprockets => {
            :context => context,
            :environment => context.environment
          }
        }

        sass_config = context.environment.context_class.sass_config.merge(options)

        result = ::Sass::Engine.new(data, sass_config).render

        filenames = ([options[:importer].imported_filenames] + options[:load_path].map(&:imported_filenames)).flatten.uniq
        filenames.each { |filename| context.depend_on(filename) }

        result
      rescue ::Sass::SyntaxError => e
        context.__LINE__ = e.sass_backtrace.first[:line]
        raise e
      end
    end

    class ScssTemplate < SassTemplate
      def self.default_mime_type
        'text/css'
      end

      def syntax
        :scss
      end
    end
  end
end
