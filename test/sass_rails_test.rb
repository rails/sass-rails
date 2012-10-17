require 'test_helper'

class SassRailsTest < Sass::Rails::TestCase
  test "classes are loaded" do
    assert_kind_of Module, Sass::Rails
    assert_kind_of Class, Sass::Rails::CssCompressor
    assert_kind_of Class, Sass::Rails::Railtie
  end

  test "style config item is honored" do
    within_rails_app "alternate_config_project" do
      runcmd "ruby script/rails runner 'puts Rails.application.config.sass.style'", Dir.pwd, true, "Gemfile", {"RAILS_ENV" => "development"}
      assert_output(/compact/)
    end
  end

  test "css_compressor config item is honored" do
    within_rails_app "alternate_config_project" do
      runcmd "ruby script/rails runner 'puts Rails.application.config.assets.css_compressor'", Dir.pwd, true, "Gemfile", {"RAILS_ENV" => "production"}
      assert_output(/yui/)
    end
  end

  # This tests both the railtie responsible for passing in the :compact style, and the compressor for honoring it
  test "compressor outputs compact style when specified in config" do
    command =<<END_OF_COMMAND
puts Rails.application.config.assets.css_compressor.compress(<<CSS)
div {
  color: red;
}
span {
  color: blue;
}
CSS
END_OF_COMMAND
    within_rails_app "alternate_config_project" do
      runcmd "ruby script/rails runner '#{command}'", Dir.pwd, true, "Gemfile", {"RAILS_ENV" => "development"}
      assert_line_count(3)
    end
  end

  test "compressor outputs compressed style when no style is specified but compression is true" do
    command =<<END_OF_COMMAND
puts Rails.application.config.assets.css_compressor.compress(<<CSS)
div {
  color: red;
}
span {
  color: blue;
}
CSS
END_OF_COMMAND
    within_rails_app "alternate_config_project" do
      runcmd "ruby script/rails runner '#{command}'", Dir.pwd, true, "Gemfile", {"RAILS_ENV" => "test"}
      assert_line_count(1)
    end
  end

  test "sass uses expanded style by default when no compression" do
    within_rails_app "scss_project" do
      runcmd "ruby script/rails runner 'puts Rails.application.config.sass.style'", Dir.pwd, true, "Gemfile", {"RAILS_ENV" => "development"}
      assert_output(/expanded/)
    end
  end

  test "scss files are generated during scaffold generation of scss projects" do
    within_rails_app "scss_project" do
      generate_scaffold
      assert_file_exists "app/assets/stylesheets/foos.css.scss"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.scss"
      assert_not_output(/conflict/)
    end
  end

  test "sass files are generated during scaffold generation of sass projects" do
    within_rails_app "sass_project" do
      generate_scaffold
      assert_file_exists "app/assets/stylesheets/foos.css.sass"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.sass"
      assert_not_output(/conflict/)
    end
  end

  test "scss files are generated during scaffold generation of a engine project" do
    within_rails_app "engine_project" do
      generate_scaffold
      assert_file_exists "app/assets/stylesheets/engine_project/foos.css.scss"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.scss"
      assert_not_output(/conflict/)
    end
  end

  test "sass files are generated during scaffold generation of a engine project, if is called with --stylesheet-engine=sass" do
    within_rails_app "engine_project" do
      generate_scaffold "--stylesheet-engine=sass"
      assert_file_exists "app/assets/stylesheets/engine_project/foos.css.sass"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.sass"
      assert_not_output(/conflict/)
    end
  end

  # DISABLED because we've removed the feature for now.
  # test "scss template has correct dasherized css class for namespaced controllers" do
  #   within_rails_app "scss_project" do
  #     runcmd "rails generate controller foo/bar"
  #     assert_file_exists "app/assets/stylesheets/foo/bar.css.scss"
  #     assert_match /\.foo-bar/, File.read("app/assets/stylesheets/foo/bar.css.scss")
  #   end
  # end
  #
  # test "sass template has correct dasherized css class for namespaced controllers" do
  #   within_rails_app "sass_project" do
  #     runcmd "rails generate controller foo/bar"
  #     assert_file_exists "app/assets/stylesheets/foo/bar.css.sass"
  #     assert_match /\.foo-bar/, File.read("app/assets/stylesheets/foo/bar.css.sass")
  #   end
  # end
  #
  test "sprockets require works correctly" do
    css_output = sprockets_render("scss_project", "css_application.css")
    assert_match /globbed/, css_output
  end

  test "sass imports work correctly" do
    css_output = sprockets_render("scss_project", "application.css.scss")
    assert_match /main/,                     css_output
    assert_match /top-level/,                css_output
    assert_match /partial-sass/,             css_output
    assert_match /partial-scss/,             css_output
    assert_match /sub-folder-relative-sass/, css_output
    assert_match /sub-folder-relative-scss/, css_output
    assert_match /not-a-partial/,            css_output
    assert_match /globbed/,                  css_output
    assert_match /nested-glob/,              css_output
    assert_match /plain-old-css/,            css_output
    assert_match /another-plain-old-css/,    css_output
    assert_match /without-css-ext/,          css_output
  end

  test "sass asset paths work" do
    css_output = sprockets_render("scss_project", "application.css.scss")
    assert_match %r{asset-path:\s*"/assets/rails.png"},                            css_output, 'asset-path:\s*"/assets/rails.png"'
    assert_match %r{asset-url:\s*url\(/assets/rails.png\)},                        css_output, 'asset-url:\s*url\(/assets/rails.png\)'
    assert_match %r{image-path:\s*"/assets/rails.png"},                            css_output, 'image-path:\s*"/assets/rails.png"'
    assert_match %r{image-url:\s*url\(/assets/rails.png\)},                        css_output, 'image-url:\s*url\(/assets/rails.png\)'
    assert_match %r{video-path:\s*"/assets/rails.mp4"},                            css_output, 'video-path:\s*"/assets/rails.mp4"'
    assert_match %r{video-url:\s*url\(/assets/rails.mp4\)},                        css_output, 'video-url:\s*url\(/assets/rails.mp4\)'
    assert_match %r{audio-path:\s*"/assets/rails.mp3"},                            css_output, 'audio-path:\s*"/assets/rails.mp3"'
    assert_match %r{audio-url:\s*url\(/assets/rails.mp3\)},                        css_output, 'audio-url:\s*url\(/assets/rails.mp3\)'
    assert_match %r{font-path:\s*"/assets/rails.ttf"},                             css_output, 'font-path:\s*"/assets/rails.ttf"'
    assert_match %r{font-url:\s*url\(/assets/rails.ttf\)},                         css_output, 'font-url:\s*url\(/assets/rails.ttf\)'
    assert_match %r{font-url-with-query-hash:\s*url\(/assets/rails.ttf\?#iefix\)}, css_output, 'font-url:\s*url\(/assets/rails.ttf?#iefix\)'
    assert_match %r{javascript-path:\s*"/assets/rails.js"},                        css_output, 'javascript-path:\s*"/assets/rails.js"'
    assert_match %r{javascript-url:\s*url\(/assets/rails.js\)},                    css_output, 'javascript-url:\s*url\(/assets/rails.js\)'
    assert_match %r{stylesheet-path:\s*"/assets/rails.css"},                       css_output, 'stylesheet-path:\s*"/assets/rails.css"'
    assert_match %r{stylesheet-url:\s*url\(/assets/rails.css\)},                   css_output, 'stylesheet-url:\s*url\(/assets/rails.css\)'

    asset_data_url_regexp = %r{asset-data-url:\s*url\((.*?)\)}
    assert_match asset_data_url_regexp, css_output, 'asset-data-url:\s*url\((.*?)\)'
    asset_data_url_match = css_output.match(asset_data_url_regexp)[1]
    asset_data_url_expected = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw%2FeHBhY2tldCBiZWdpbj0i77u%2FIiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8%2BIDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1NzowMSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNS4xIE1hY2ludG9zaCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpCNzY5NDE1QkQ2NkMxMUUwOUUzM0E5Q0E2RTgyQUExQiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpCNzY5NDE1Q0Q2NkMxMUUwOUUzM0E5Q0E2RTgyQUExQiI%2BIDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOkE3MzcyNTQ2RDY2QjExRTA5RTMzQTlDQTZFODJBQTFCIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkI3Njk0MTVBRDY2QzExRTA5RTMzQTlDQTZFODJBQTFCIi8%2BIDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY%2BIDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8%2B0HhJ9AAAABBJREFUeNpi%2BP%2F%2FPwNAgAEACPwC%2FtuiTRYAAAAASUVORK5CYII%3D"
    assert_equal asset_data_url_expected, asset_data_url_match
  end

  test "css compressor compresses" do
    assert_equal "div{color:red}\n", Sass::Rails::CssCompressor.new.compress(<<CSS)
div {
  color: red;
}
CSS
  end

  def generate_scaffold(args = nil)
    runcmd "bundle exec rails generate scaffold foo #{args}"
  end
end
