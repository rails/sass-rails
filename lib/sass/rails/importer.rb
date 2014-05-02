require 'sprockets/sass_importer'

module Sass
  module Rails
    class SassImporter < Sass::Importers::Filesystem
      GLOB = /\*|\[.+\]/

      attr_reader :context
      def initialize(context, *args)
        @context = context
        super(*args)
      end

      def extensions
        {
          'css'          => :scss,
          'css.scss'     => :scss,
          'css.sass'     => :sass,
          'css.erb'      => :scss,
          'scss.erb'     => :scss,
          'sass.erb'     => :sass,
          'css.scss.erb' => :scss,
          'css.sass.erb' => :sass
        }.merge!(super)
      end

      def find_relative(name, base, options)
        if name =~ GLOB
          glob_imports(name, Pathname.new(base), options)
        else
          engine_from_path(name, File.dirname(base), options)
        end
      end

      def find(name, options)
        if name =~ GLOB
          nil # globs must be relative
        else
          engine_from_path(name, root, options)
        end
      end

      private

        def each_globbed_file(glob, base_pathname, options)
          Dir["#{base_pathname}/#{glob}"].sort.each do |filename|
            next if filename == options[:filename]
            if File.directory?(filename)
              context.depend_on(filename)
              context.depend_on(File.expand_path('..', filename))
            elsif context.asset_requirable?(filename)
              context.depend_on(File.dirname(filename))
              yield filename
            end
          end
        end

        def glob_imports(glob, base_pathname, options)
          contents = ""
          each_globbed_file(glob, base_pathname.dirname, options) do |filename|
            contents << "@import #{Pathname.new(filename).relative_path_from(base_pathname.dirname).to_s.inspect};\n"
          end
          return nil if contents.empty?
          Sass::Engine.new(contents, options.merge(
            :filename => base_pathname.to_s,
            :importer => self,
            :syntax => :scss
          ))
        end


        def engine_from_path(name, dir, options)
          full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
          return unless full_filename && File.readable?(full_filename)

          context.depend_on full_filename
          engine = Sass::Engine.new(evaluate(full_filename), options.merge(
            syntax: syntax,
            filename: full_filename,
            importer: self
          ))

          engine
        end

        def evaluate(filename)
          attributes = context.environment.attributes_for(filename)
          processors = context.environment.preprocessors(attributes.content_type) +
            attributes.engines.reverse - [Sass::Rails::ScssTemplate, Sass::Rails::SassTemplate]

          context.evaluate(filename, processors: processors)
        end

    end
  end
end
