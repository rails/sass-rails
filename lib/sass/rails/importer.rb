require 'sprockets'

module Sass::Rails
  class Importer
    GLOB = /\*|\[.+\]/
    PARTIAL = /^_/
    HAS_EXTENSION = /\.css(.s[ac]ss)?$/

    SASS_EXTENSIONS = {
      ".css.sass" => :sass,
      ".css.scss" => :scss,
      ".sass" => :sass,
      ".scss" => :scss
    }
    attr_reader :context

    def initialize(context)
      @context = context
      @resolver = Resolver.new(context)
    end

    def sass_file?(filename)
      filename = filename.to_s
      SASS_EXTENSIONS.keys.any?{|ext| filename[ext]}
    end

    def syntax(filename)
      filename = filename.to_s
      SASS_EXTENSIONS.each {|ext, syntax| return syntax if filename[(ext.size+2)..-1][ext]}
      nil
    end

    def resolve(name, base_pathname = nil)
      name = Pathname.new(name)
      if base_pathname && base_pathname.to_s.size > 0
        root = Pathname.new(context.root_path)
        name = base_pathname.relative_path_from(root).join(name)
      end
      partial_name = name.dirname.join("_#{name.basename}")
      @resolver.resolve(name) || @resolver.resolve(partial_name)
    end

    def find_relative(name, base, options)
      base_pathname = Pathname.new(base)
      if name =~ GLOB
        glob_imports(name, base_pathname, options)
      elsif pathname = resolve(name, base_pathname.dirname)
        context.depend_on(pathname)
        if sass_file?(pathname)
          Sass::Engine.new(pathname.read, options.merge(:filename => pathname.to_s, :importer => self, :syntax => syntax(pathname)))
        else
          Sass::Engine.new(@resolver.process(pathname), options.merge(:filename => pathname.to_s, :importer => self, :syntax => :scss))
        end
      else
        nil
      end
    end

    def find(name, options)
      if name =~ GLOB
        nil # globs must be relative
      elsif pathname = resolve(name)
        context.depend_on(pathname)
        if sass_file?(pathname)
          Sass::Engine.new(pathname.read, options.merge(:filename => pathname.to_s, :importer => self, :syntax => syntax(pathname)))
        else
          Sass::Engine.new(@resolver.process(pathname), options.merge(:filename => pathname.to_s, :importer => self, :syntax => :scss))
        end
      else
        nil
      end
    end

    def each_globbed_file(glob, base_pathname, options)
      Dir["#{base_pathname}/#{glob}"].sort.each do |filename|
        next if filename == options[:filename]
        yield filename if File.directory?(filename) || context.asset_requirable?(filename)
      end
    end

    def glob_imports(glob, base_pathname, options)
      contents = ""
      each_globbed_file(glob, base_pathname.dirname, options) do |filename|
        if File.directory?(filename)
          context.depend_on(filename)
        elsif context.asset_requirable?(filename)
          context.depend_on(filename)
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

    def mtime(name, options)
      if name =~ GLOB && options[:filename]
        mtime = nil
        each_globbed_file(name, Pathname.new(options[:filename]).dirname, options) do |p|
          mtime ||= File.mtime(p)
          mtime = [mtime, File.mtime(p)].max
        end
        mtime
      elsif pathname = resolve(name)
        pathname.mtime
      end
    end

    def key(name, options)
      ["Sprockets:" + File.dirname(File.expand_path(name)), File.basename(name)]
    end

    def to_s
      "Sass::Rails::Importer(#{context.pathname})"
    end

  end

end