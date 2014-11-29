require 'sass'
require 'sprockets/sass_importer'
require 'tilt'

module Sass
  module Rails
    class SassImporter < Sass::Importers::Filesystem
      module Globbing
        GLOB = /\*|\[.+\]/

        def find_relative(name, base, options)
          if name =~ GLOB
            glob_imports(name, Pathname.new(base), options)
          else
            super
          end
        end

        def find(name, options)
          # globs must be relative
          return if name =~ GLOB
          super
        end

        private
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

          def each_globbed_file(glob, base_pathname, options)
            Dir["#{base_pathname}/#{glob}"].sort.each do |path|
              if path == options[:filename]
                # skip importing self
              elsif File.directory?(path)
                context.depend_on(path)
                context.depend_on(File.expand_path("..", path))
              elsif importable?(path)
                yield path
              end
            end
          end

          def importable?(filename)
            exts = extensions.keys.map { |ext| Regexp.escape(".#{ext}") }.join("|")
            Regexp.compile("(#{exts})$") =~ filename
          end
      end

      module ERB
        def extensions
          {
            'css.erb'  => :scss_erb,
            'scss.erb' => :scss_erb,
            'sass.erb' => :sass_erb
          }.merge(super)
        end

        def erb_extensions
          {
            :scss_erb => :scss,
            :sass_erb => :sass
          }
        end

        def find_relative(name, base, options)
          filename, syntax = find_filename(File.dirname(base), name, options)

          if syntax = erb_extensions[syntax]
            erb_engine(filename, syntax, options)
          else
            super
          end
        end

        def find(name, options)
          filename, syntax = find_filename(root, name, options)

          if syntax = erb_extensions[syntax]
            erb_engine(filename, syntax, options)
          else
            super
          end
        end

        private
          def find_filename(dir, name, options)
            full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
            if full_filename && File.readable?(full_filename)
              return full_filename, syntax
            end
          end

          def erb_engine(filename, syntax, options)
            options[:syntax]   = syntax
            options[:filename] = filename
            options[:importer] = self

            template = Tilt::ERBTemplate.new(filename) { File.read(filename) }
            contents = template.render(context, {})

            Sass::Engine.new(contents, options)
          end
      end

      include ERB
      include Globbing

      attr_reader :context

      def initialize(context, *args)
        @context = context
        super(*args)
      end

      # Allow .css files to be @import'd
      def extensions
        { 'css' => :scss }.merge(super)
      end
    end
  end
end
