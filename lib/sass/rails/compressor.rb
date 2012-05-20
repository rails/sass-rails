require 'sass'

module Sass
  module Rails
    class CssCompressor
      def initialize(options={})
        @options = {:style => :compressed}.merge(options)
      end

      def compress(css)
        if css.count("\n") > 2
          Sass::Engine.new(css,
                           :syntax => :scss,
                           :cache => false,
                           :read_cache => false,
                           :style => @options[:style]).render # note: style is set by railtie or by config
        else
          css
        end
      end
    end
  end
end
