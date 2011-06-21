require 'test_helper'

class SassRailsLoggerTest < Sass::Rails::TestCase
  test "setting a sass-rails logger as the sass default logger" do
    assert Sass::logger.is_a?(Sass::Rails::Logger)
  end

  log_levels = [:debug, :warn, :error, :info]
  log_levels.each do |level|

    test "calling the  sass #{level} logger passes the message to rails #{level} logger" do
      message = "debug message"
      Rails.logger.expects(:debug).with(message)
      Sass::logger.log(:debug, message)
    end

  end

  test "calling the sass trace logger uses the built-in sass logger" do
    Sass::logger.expects(:super)
    Sass::logger.log(:trace, "trace message")
  end
end
