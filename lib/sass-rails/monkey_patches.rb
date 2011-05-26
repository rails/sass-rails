require 'sprockets/railtie'

module Sprockets
  class Railtie < ::Rails::Railtie
    protected
    def asset_environment_with_sass_config(app, *args)
      env = asset_environment_without_sass_config(app, *args)
      env.opaque_data = { :sass_config => app.config.sass }
      env
    end
    alias_method_chain :asset_environment, :sass_config
  end
end