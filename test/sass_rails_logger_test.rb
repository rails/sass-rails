require 'test_helper'

class SassRailsLoggerTest < Sass::Rails::TestCase
  test "setting a sass-rails logger as the sass default logger" do
    within_rails_app "scss_project" do
      logger_class_name = runcmd 'rails runner "print Sass::logger.class.name"'
      assert_equal Sass::Rails::Logger.name, logger_class_name
    end
  end

  [:debug, :warn, :info, :error, :trace].each do |level|
    test "sending a #{level} message to the sass logger writes to the environment log file" do
      within_rails_app "scss_project" do
        app_root = runcmd 'rails runner "print Rails.root"'

        message = "[#{level}]: sass message"
        runcmd %{rails runner "Sass::logger.log_level = :#{level}; Sass::logger.log(:#{level}, %Q|#{message}|)"}

        log_output = File.open("#{app_root}/log/development.log").read
        assert log_output.include?(message), "the #{level} log message was not found in the log file"
      end
    end
  end
end
