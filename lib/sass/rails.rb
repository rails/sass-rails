module Sass
  module Rails
    autoload :CssCompressor, 'sass/rails/compressor'
    autoload :Logger,        'sass/rails/logger'
  end
end

require 'sass/rails/version'
require 'sass/rails/helpers'
require 'sass/rails/importer'
require 'sass/rails/railtie'
