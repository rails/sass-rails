module Sass::Rails::SassContext
  attr_accessor :sass_config
end

module Sass::Rails::SprocketsConfig
  def self.included(base)
    base.alias_method_chain :asset_environment, :sass_config
  end

  def asset_environment_with_sass_config(app, *args)
    env = asset_environment_without_sass_config(app, *args)
    env.context_class.extend(Sass::Rails::SassContext)
    env.context_class.sass_config = app.config.sass
    env
  end
end

begin
  # Before sprockets was extracted from rails
  require 'sprockets/railtie'
  module Sprockets
    class Railtie < ::Rails::Railtie
      include Sass::Rails::SprocketsConfig
    end
  end
rescue LoadError
  # After sprockets was extracted into sprockets-rails
  require 'sprockets/rails/railtie'
  module Sprockets
    module Rails
      class Railtie < ::Rails::Railtie
        include Sass::Rails::SprocketsConfig
      end
    end
  end
end