require 'sprockets/sass_importer'

module Sprockets
  class SassImporter < Sass::Importers::Filesystem
    GLOB = /\*|\[.+\]/

    def extensions
      {
        "css" => :scss,
        "css.sass" => :sass,
        "css.scss" => :scss
      }.merge!(super)
    end

    def find_relative_with_glob(name, base, options)
      if name =~ GLOB
        glob_imports(name, Pathname.new(base), options)
      else
        find_relative_without_glob(name, base, options)
      end
    end
    alias_method :find_relative_without_glob, :find_relative
    alias_method :find_relative, :find_relative_with_glob

    def find_with_glob(name, options)
      if name =~ GLOB
        nil # globs must be relative
      else
        find_without_glob(name, options)
      end
    end
    alias_method :find_without_glob, :find
    alias_method :find, :find_with_glob

    def each_globbed_file(glob, base_pathname, options)
      Dir["#{base_pathname}/#{glob}"].sort.each do |filename|
        next if filename == options[:filename]
        yield filename if File.directory?(filename) || @context.asset_requirable?(filename)
      end
    end

    def glob_imports(glob, base_pathname, options)
      contents = ""
      each_globbed_file(glob, base_pathname.dirname, options) do |filename|
        if File.directory?(filename)
          @context.depend_on(filename)
        elsif @context.asset_requirable?(filename)
          @context.depend_on(filename)
          contents << "@import #{Pathname.new(filename).relative_path_from(base_pathname.dirname).to_s.inspect};\n"
        end
      end
      return nil if contents.empty?
      Sass::Engine.new(contents, options.merge(
        :filename => base_pathname.to_s,
        :importer => self,
        :syntax => :scss
      ))
    end
  end
end
