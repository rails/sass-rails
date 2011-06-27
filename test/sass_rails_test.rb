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
  test "sass files are generated during scaffold generation of sass projects" do
    within_rails_app "sass_project" do
      runcmd "rails generate scaffold foo"
      assert_file_exists "app/assets/stylesheets/foos.css.sass"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.sass"
      assert_not_output(/conflict/)
    end
  end
  test "scss template has correct dasherized css class for namespaced controllers" do
    within_rails_app "scss_project" do
      runcmd "rails generate controller foo/bar"
      assert_file_exists "app/assets/stylesheets/foo/bar.css.scss"
      assert_match File.read("app/assets/stylesheets/foo/bar.css.scss"), /\.foo-bar/
    end
  end
  test "sass template has correct dasherized css class for namespaced controllers" do
    within_rails_app "sass_project" do
      runcmd "rails generate controller foo/bar"
      assert_file_exists "app/assets/stylesheets/foo/bar.css.sass"
      assert_match File.read("app/assets/stylesheets/foo/bar.css.sass"), /\.foo-bar/
    end
  end
  test "templates are registered with sprockets" do
    assert_equal Sass::Rails::SassTemplate, Sprockets.engines[".sass"]
    assert_equal Sass::Rails::ScssTemplate, Sprockets.engines[".scss"]
  end
  test "sprockets require works correctly" do
    css_output = sprockets_render("scss_project", "css_application.css")
    assert_match css_output, /globbed/
  end
  test "sass imports work correctly" do
    css_output = sprockets_render("scss_project", "application.css.scss")
    assert_match css_output, /main/
    assert_match css_output, /top-level/
    assert_match css_output, /partial-sass/
    assert_match css_output, /partial-scss/
    assert_match css_output, /sub-folder-relative-sass/
    assert_match css_output, /sub-folder-relative-scss/
    assert_match css_output, /not-a-partial/
    assert_match css_output, /globbed/
    assert_match css_output, /nested-glob/
    assert_match css_output, /plain-old-css/
    assert_match css_output, /another-plain-old-css/
  end
  test "sass asset paths work" do
    css_output = sprockets_render("scss_project", "application.css.scss")
    assert_match css_output, %r{asset-path:\s*"/assets/rails.png"}
    assert_match css_output, %r{asset-url:\s*url\(/assets/rails.png\)}
    assert_match css_output, %r{image-url:\s*url\(/assets/rails.png\)}
  end
  test "css compressor compresses" do
    assert_equal "div{color:red}\n", Sass::Rails::CssCompressor.new.compress(<<CSS)
div {
  color: red;
}
CSS
  end
end
