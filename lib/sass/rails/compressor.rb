require 'sass'

module Sass
  module Rails
    class CssCompressor
      def compress(css)
        if css.count("\n") > 2
          Sass::Engine.new(css,
                           :syntax => :scss,
                           :cache => false,
                           :read_cache => false,
                           :style => :compressed).render
        else
          css
        end
      end
    end
  end
end
