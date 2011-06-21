module Sass
  module Rails
    class Logger < Sass::Logger::Base
      def _log(level, message)
        logger = ::Rails.logger

        if logger.respond_to? level
          logger.send(level, message)
        else
          super
        end
      end
    end
  end
end

Sass::logger = Sass::Rails::Logger.new
