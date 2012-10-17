module Sass
  autoload :Script, 'sass/rails/helpers'

  module Rails
    autoload :CssCompressor, 'sass/rails/compressor'
    autoload :Importer,      'sass/rails/importer'
    autoload :Logger,        'sass/rails/logger'
  end
end

require 'sass/rails/version'
require 'sass/rails/helpers'
require 'sass/rails/railtie'
