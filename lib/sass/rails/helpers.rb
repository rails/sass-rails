module Sass
  module Rails
    module Helpers

      def asset_data_url(path)
        data = context_asset_data_uri(path.value)
        Sass::Script::String.new(%Q{url(#{data})})
      end

      def asset_path(asset, kind)
        Sass::Script::String.new(public_path(asset.value, kind.value), true)
      end

      def asset_url(asset, kind)
        Sass::Script::String.new(%Q{url(#{public_path(asset.value, kind.value)})})
      end

      [:image, :video, :audio, :javascript, :stylesheet, :font].each do |asset_class|
        class_eval %Q{
          def #{asset_class}_path(asset)
            Sass::Script::String.new(resolver.#{asset_class}_path(asset.value), true)
          end
          def #{asset_class}_url(asset)
            Sass::Script::String.new("url(" + resolver.#{asset_class}_path(asset.value) + ")")
          end
        }, __FILE__, __LINE__ - 6
      end

    protected

    def resolver
      options[:custom][:resolver]
    end

    def public_path(asset, kind)
      resolver.public_path(asset, kind.pluralize)
    end

    def context_asset_data_uri(path)
      resolver.context.asset_data_uri(path)
    end
    end
  end
end

module Sass
  module Script
    module Functions
      include Sass::Rails::Helpers
    end
  end
end
