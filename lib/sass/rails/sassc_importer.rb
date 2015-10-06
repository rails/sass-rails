require "sassc"

module SassC
  class Engine
    def options
      @options
    end

    def template
      @template
    end

    def filename
      @options[:filename]
    end
  end
end

module Sass
  module Rails
    class SasscImporter < SassC::Importer
      def imports(path, parent_path)
        context = options[:sprockets][:context]
        root = Pathname.new(context.filename).to_s
        lookup = FileLookup.new(root)

        engine = lookup.find_relative(path, parent_path, options)
        template = engine.template

        if engine.options[:syntax] == :sass
          template = SassC::Sass2Scss.convert(template)
        end

        context.depend_on(engine.filename)

        SassC::Importer::Import.new(engine.filename, source: template)
      end

      class FileLookup < SassImporter
        private
          def _find(dir, name, options)
            # this is copied from Sass, save for the last line.

            full_filename, syntax = Sass::Util.destructure(find_real_file(dir, name, options))
            return unless full_filename && File.readable?(full_filename)

            full_filename = full_filename.tr("\\", "/") if Sass::Util.windows?

            options[:syntax] = syntax
            options[:filename] = full_filename
            options[:importer] = self

            SassC::Engine.new(File.read(full_filename), options)
          end

          def sass_engine(*args)
            SassC::Engine.new(*args)
          end
      end
    end
  end
end
