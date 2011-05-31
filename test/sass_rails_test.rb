require 'test_helper'

class SassRailsTest < Sass::Rails::TestCase
  test "classes are loaded" do
    assert_kind_of Module, Sass::Rails
    assert_kind_of Class, Sass::Rails::CssCompressor
    assert_kind_of Class, Sass::Rails::Railtie
  end
  test "scss files are generated during scaffold generation of scss projects" do
    within_rails_app "scss_project" do
      runcmd "rails generate scaffold foo"
      assert_file_exists "app/assets/stylesheets/foos.css.scss"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.scss"
      assert_not_output(/conflict/)
    end
  end
  test "sass files are generated during scaffold generation sass projects" do
    within_rails_app "sass_project" do
      runcmd "rails generate scaffold foo"
      assert_file_exists "app/assets/stylesheets/foos.css.sass"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.sass"
      assert_not_output(/conflict/)
    end
  end
end
