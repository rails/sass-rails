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

      [:image, :font, :video, :audio, :javascript, :stylesheet].each do |asset_class|
        class_eval %Q{
          def #{asset_class}_path(asset)
            asset_path(asset, Sass::Script::String.new("#{asset_class}"))
          end
          def #{asset_class}_url(asset)
            asset_url(asset, Sass::Script::String.new("#{asset_class}"))
          end
        }, __FILE__, __LINE__ - 6
      end

    protected
      def public_path(asset, kind)
        options[:custom][:resolver].public_path(asset, kind.pluralize)
      end
      
      def context_asset_data_uri(path)
        options[:custom][:resolver].context.asset_data_uri(path)
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