require 'test_helper'

class SassRailsTest < Sass::Rails::TestCase
  test "classes are loaded" do
    assert_kind_of Module, Sass::Rails
    assert_kind_of Class, Sass::Rails::CssCompressor
    assert_kind_of Class, Sass::Rails::Railtie
  end
  test "scss files are generated during scaffold generation" do
    within_rails_app "scss_project" do
      runcmd "rails g scaffold foo"
      assert_file_exists "app/assets/stylesheets/foos.css.scss"
      assert_not_output(/conflict/)
    end
  end
end
