require 'sprockets'

module Sass::Rails
  class Importer
    PARTIAL = /^_/
    HAS_EXTENSION = /\.css(.s[ac]ss)?$/

    SASS_EXTENSIONS = {
      ".css.sass" => :sass,
      ".css.scss" => :scss
    }
    attr_reader :context

    def initialize(context)
      @context = context
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
        name = base_pathname.dirname.relative_path_from(context.pathname.dirname).join(name)
      end
      partial_name = name.dirname.join("_#{name.basename}")
      sprockets_resolve(name) || sprockets_resolve(partial_name)
    end

    def find_relative(name, base, options)
      base_pathname = Pathname.new(base)
      if pathname = resolve(name, base_pathname)
        if sass_file?(pathname)
          Sass::Engine.new(pathname.read, options.merge(:filename => pathname.to_s, :importer => self, :syntax => syntax(pathname)))
        else
          Sass::Engine.new(sprockets_process(pathname), options.merge(:filename => pathname.to_s, :importer => self, :syntax => :scss))
        end
      else
        nil
      end
    end

    def find(name, options)
      if pathname = resolve(name)
        if sass_file?(pathname)
          Sass::Engine.new(pathname.read, options.merge(:filename => pathname.to_s, :importer => self, :syntax => syntax(pathname)))
        else
          Sass::Engine.new(sprockets_process(pathname), options.merge(:filename => pathname.to_s, :importer => self, :syntax => :scss))
        end
      else
        nil
      end
    end

    def mtime(name, options)
      if pathname = resolve(name)
        pathname.mtime
      end
    end

    def key(name, options)
      ["Sprockets:" + File.dirname(File.expand_path(name)), File.basename(name)]
    end

    def to_s
      "Sass::Rails::Importer(#{context.pathname})"
    end

    private
      def sprockets_resolve(path)
        context.resolve(path, :content_type => :self)
      rescue Sprockets::FileNotFound
        nil
      end
  end

end