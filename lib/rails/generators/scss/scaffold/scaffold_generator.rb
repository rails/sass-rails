require "rails/generators/sass_scaffold"

module Scss
  module Generators
    class ScaffoldGenerator < ::Sass::Generators::SassScaffold
      def syntax() :scss end
    end
  end
end

