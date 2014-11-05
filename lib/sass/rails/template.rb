require "sprockets/sass_template"

module Sass
  module Rails
    class SassTemplate < Sprockets::SassTemplate
      def call(input)
        context = input[:environment].context_class.new(input)

        options = {
          filename: input[:filename],
          syntax: self.class.syntax,
          cache_store: CacheStore.new(input[:cache], @cache_version),
          importer: SassImporter.new(context, context.pathname.to_s),
          load_paths: input[:environment].paths.map { |path| SassImporter.new(context, path.to_s) },
          sprockets: {
            context: context,
            environment: input[:environment],
            dependencies: context.metadata[:dependency_paths]
          }
        }

        engine = ::Sass::Engine.new(input[:data], options)

        css = Sprockets::Utils.module_include(::Sass::Script::Functions, @functions) do
          engine.render
        end

        # Track all imported files
        engine.dependencies.map do |dependency|
          context.metadata[:dependency_paths] << dependency.options[:filename]
        end

        context.metadata.merge(data: css)
      end
    end

    class ScssTemplate < SassTemplate
      def self.syntax
        :scss
      end
    end
  end
end
