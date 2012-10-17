require 'sprockets/sass_functions'

module Sass
  module Rails
    module Helpers
      def asset_data_url(path)
        Sass::Script::String.new("url(" + sprockets_context.asset_data_uri(path.value) + ")")
      end
    end
  end
end

module Sprockets
  module SassFunctions
    include Sass::Rails::Helpers
  end
end
