module Sass
  module Rails
    autoload :Logger, 'sass/rails/logger'
  end
end

require 'sass/rails/version'
require 'sass/rails/sass_importer'
require 'sass/rails/railtie'

begin
  require 'sass/rails/sassc_importer'
rescue LoadError
end
