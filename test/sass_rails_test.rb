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
  test "scss files are generated during scaffold generation of a engine project" do
    within_rails_app "engine_project" do
      runcmd "rails generate scaffold foo"
      assert_file_exists "app/assets/stylesheets/engine_project/foos.css.scss"
      assert_file_exists "app/assets/stylesheets/scaffolds.css.scss"
      assert_not_output(/conflict/)
    end
  end
  test "sass files are generated during scaffold generation of a engine project, if is called with --stylesheet-engine=sass" do
    within_rails_app "engine_project" do
      runcmd "rails generate scaffold foo --stylesheet-engine=sass"
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
  # test "sass template has correct dasherized css class for namespaced controllers" do
  #   within_rails_app "sass_project" do
  #     runcmd "rails generate controller foo/bar"
  #     assert_file_exists "app/assets/stylesheets/foo/bar.css.sass"
  #     assert_match /\.foo-bar/, File.read("app/assets/stylesheets/foo/bar.css.sass")
  #   end
  # end
  test "sprockets require works correctly" do
    css_output = sprockets_render("scss_project", "css_application.css")
    assert_match /globbed/, css_output
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
    assert_match css_output, /without-css-ext/
  end
  test "sass asset paths work" do
    css_output = sprockets_render("scss_project", "application.css.scss")
    assert_match css_output, %r{asset-path:\s*"/assets/rails.png"}, 'asset-path:\s*"/assets/rails.png"'
    assert_match css_output, %r{asset-url:\s*url\(/assets/rails.png\)}, 'asset-url:\s*url\(/assets/rails.png\)'
    assert_match css_output, %r{image-path:\s*"/assets/rails.png"}, 'image-path:\s*"/assets/rails.png"'
    assert_match css_output, %r{image-url:\s*url\(/assets/rails.png\)}, 'image-url:\s*url\(/assets/rails.png\)'
    assert_match css_output, %r{video-path:\s*"/videos/rails.mp4"}, 'video-path:\s*"/videos/rails.mp4"'
    assert_match css_output, %r{video-url:\s*url\(/videos/rails.mp4\)}, 'video-url:\s*url\(/videos/rails.mp4\)'
    assert_match css_output, %r{audio-path:\s*"/audios/rails.mp3"}, 'audio-path:\s*"/audios/rails.mp3"'
    assert_match css_output, %r{audio-url:\s*url\(/audios/rails.mp3\)}, 'audio-url:\s*url\(/audios/rails.mp3\)'
    assert_match css_output, %r{font-path:\s*"/assets/rails.ttf"}, 'font-path:\s*"/assets/rails.ttf"'
    assert_match css_output, %r{font-url:\s*url\(/assets/rails.ttf\)}, 'font-url:\s*url\(/assets/rails.ttf\)'
    assert_match css_output, %r{font-url-with-query-hash:\s*url\(/assets/rails.ttf\?#iefix\)}, 'font-url:\s*url\(/assets/rails.ttf?#iefix\)'
    assert_match css_output, %r{javascript-path:\s*"/assets/rails.js"}, 'javascript-path:\s*"/assets/rails.js"'
    assert_match css_output, %r{javascript-url:\s*url\(/assets/rails.js\)}, 'javascript-url:\s*url\(/assets/rails.js\)'
    assert_match css_output, %r{stylesheet-path:\s*"/assets/rails.css"}, 'stylesheet-path:\s*"/assets/rails.css"'
    assert_match css_output, %r{stylesheet-url:\s*url\(/assets/rails.css\)}, 'stylesheet-url:\s*url\(/assets/rails.css\)'

    asset_data_url_regexp = %r{asset-data-url:\s*url\((.*?)\)}
    assert_match css_output, asset_data_url_regexp, 'asset-data-url:\s*url\((.*?)\)'
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
end
