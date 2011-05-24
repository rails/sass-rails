require "rails/generators/sass_scaffold"

module Sass
  module Generators
    class ScaffoldGenerator < ::Sass::Generators::SassScaffold
      def syntax() :sass end
    end
  end
end
