require 'sass'

module Sass
  module Rails
    class CssCompressor
      def compress(css)
        Sass::Engine.new(css,
                         :syntax => :scss,
                         :cache => false,
                         :read_cache => false,
                         :style => :compressed).render
      end
    end
  end
end
