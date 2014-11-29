require 'sass'
require 'sprockets/sass_importer'
require 'tilt'

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
          'css.erb'      => :scss,
          'scss.erb'     => :scss,
          'sass.erb'     => :sass
        }.merge!(super)
      end

      def find_relative(name, base, options)
        if name =~ GLOB
          return glob_imports(name, Pathname.new(base), options)
        end

        filename, syntax = find_filename(File.dirname(base), name, options)

        if filename && File.extname(filename) == '.erb'
          return erb_engine(filename, syntax, options)
        end

        super
      end

      def find(name, options)
        # globs must be relative
        return if name =~ GLOB

        filename, syntax = find_filename(root, name, options)

        if filename && File.extname(filename) == '.erb'
          return erb_engine(filename, syntax, options)
        end

        super
      end

      private

        def each_globbed_file(glob, base_pathname, options)
          Dir["#{base_pathname}/#{glob}"].sort.each do |filename|
            next if filename == options[:filename]
            if File.directory?(filename)
              context.depend_on(filename)
              context.depend_on(File.expand_path('..', filename))
            elsif importable?(filename)
              context.depend_on(File.dirname(filename))
              yield filename
            end
          end
        end

        def importable?(filename)
          exts = extensions.keys.map { |ext| Regexp.escape(".#{ext}") }.join("|")
          Regexp.compile("(#{exts})$") =~ filename
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

        def find_filename(dir, name, options)
          full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
          if full_filename && File.readable?(full_filename)
            return full_filename, syntax
          end
        end

        def erb_engine(filename, syntax, options)
          options[:syntax] = syntax
          options[:filename] = filename
          options[:importer] = self

          context.depend_on filename
          contents = context.evaluate(filename, processors: [Tilt::ERBTemplate])

          Sass::Engine.new(contents, options)
        end
    end
  end
end
