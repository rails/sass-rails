require 'test_helper'

class SassRailsTest < Sass::Rails::TestCase
  test 'classes are loaded' do
    assert_kind_of Module, Sass::Rails
    assert_kind_of Class, Sass::Rails::Railtie
  end

  test 'style config item is honored in development mode' do
    within_rails_app 'alternate_config_project' do
      runner 'development' do
        "puts Rails.application.config.sass.style"
      end

      assert_output %r{compact}
    end
  end

  test 'style config item is not honored if environment is not development' do
    within_rails_app 'alternate_config_project' do
      runner 'production' do
        "p Rails.application.config.sass.style"
      end

      assert_equal 'nil', $last_output.chomp
    end
  end

  test 'css_compressor config item is not honored in development mode' do
    within_rails_app 'alternate_config_project' do
      runner 'development' do
        "p Rails.application.config.assets.css_compressor"
      end

      assert_equal 'nil', $last_output.chomp
    end
  end

  test 'css_compressor config item is honored if environment is not development' do
    within_rails_app 'alternate_config_project' do
      runner 'production' do
        "puts Rails.application.config.assets.css_compressor"
      end

      assert_output %r{yui}
    end
  end

  test 'sass uses expanded style by default in development mode' do
    within_rails_app 'scss_project' do
      runner 'development' do
        "puts Rails.application.config.sass.style"
      end

      assert_output %r{expanded}
    end
  end

  test 'sass not defines compressor in development mode' do
    within_rails_app 'scss_project' do
      runner 'development' do
        "p Rails.application.config.assets.css_compressor"
      end

      assert_equal 'nil', $last_output.chomp
    end
  end

  test 'sass defines compressor by default in test mode' do
    within_rails_app 'scss_project' do
      runner 'test' do
        "puts Rails.application.config.assets.css_compressor"
      end

      assert_equal 'sass', $last_output.chomp
    end
  end

  test 'sass allows compressor override in test mode' do
    within_rails_app 'alternate_config_project' do
      runner 'test' do
        "puts Rails.application.config.assets.css_compressor.nil?"
      end

      assert_equal 'true', $last_output.chomp
    end
  end

  test 'sass defines compressor by default in production mode' do
    within_rails_app 'scss_project' do
      runner 'production' do
        "puts Rails.application.config.assets.css_compressor"
      end

      assert_equal 'sass', $last_output.chomp
    end
  end

  test 'sprockets require works correctly' do
    within_rails_app('scss_project') do |app_root|
      css_output = asset_output('css_application.css')
      assert_match %r{globbed}, css_output

      if File.exist?("#{app_root}/log/development.log")
        log_file = "#{app_root}/log/development.log"
      elsif File.exist?("#{app_root}/log/test.log")
        log_file = "#{app_root}/log/test.log"
      else
        flunk "log file was not created"
      end

      log_output = File.open(log_file).read
      refute_match %r{Warning}, log_output
    end
  end

  test 'sass imports work correctly' do
    css_output = sprockets_render('scss_project', 'application.css')
    assert_match %r{main},                     css_output
    assert_match %r{top-level},                css_output
    assert_match %r{partial-sass},             css_output
    assert_match %r{partial-scss},             css_output
    assert_match %r{sub-folder-relative-sass}, css_output
    assert_match %r{sub-folder-relative-scss}, css_output
    assert_match %r{not-a-partial},            css_output
    assert_match %r{globbed},                  css_output
    assert_match %r{nested-glob},              css_output
    assert_match %r{nested-glob-erb},          css_output
    assert_match %r{nested-glob-erb-css-scss}, css_output
    assert_match %r{plain-old-css},            css_output
    assert_match %r{another-plain-old-css},    css_output
    assert_match %r{without-css-ext},          css_output
    assert_match %r{css-erb-handler},          css_output
    assert_match %r{scss-erb-handler},         css_output
    assert_match %r{sass-erb-handler},         css_output
    assert_match %r{css-sass-erb-handler},     css_output
    assert_match %r{css-scss-erb-handler},     css_output
    assert_match %r{default-old-css},          css_output
  end

  test 'sprockets directives are ignored within an import' do
    css_output = sprockets_render('scss_project', 'import_css_application.css')
    assert_match %r{\.css-application},        css_output
    assert_match %r{\.import-css-application}, css_output
  end

  test 'globbed imports work when new file is added' do
    project = 'scss_project'
    filename = 'application.css'

    within_rails_app(project) do |tmpdir|
      asset_output(filename)

      new_file = File.join(tmpdir, 'app', 'assets', 'stylesheets', 'globbed', 'new.scss')
      File.open(new_file, 'w') do |file|
        file.puts '.new-file-test { color: #000; }'
      end

      css_output = asset_output(filename)
      assert_match %r{new-file-test}, css_output
    end
  end

  test 'globbed imports work when globbed file is changed' do
    project = 'scss_project'
    filename = 'application.css'

    within_rails_app(project) do |tmpdir|
      asset_output(filename)

      new_file = File.join(tmpdir, 'app', 'assets', 'stylesheets', 'globbed', 'globbed.scss')
      File.open(new_file, 'w') do |file|
        file.puts '.changed-file-test { color: #000; }'
      end

      css_output = asset_output(filename)
      assert_match %r{changed-file-test}, css_output
    end
  end

  test 'sass asset paths work' do
    css_output = sprockets_render('scss_project', 'application.css')
    assert_match %r{asset-path:\s*"/assets/rails(-[0-9a-f]+)?.png"},                           css_output, 'asset-path:\s*"/assets/rails.png"'
    assert_match %r{asset-url:\s*url\(/assets/rails(-[0-9a-f]+)?.png\)},                       css_output, 'asset-url:\s*url\(/assets/rails.png\)'
    assert_match %r{image-path:\s*"/assets/rails(-[0-9a-f]+)?.png"},                           css_output, 'image-path:\s*"/assets/rails.png"'
    assert_match %r{image-url:\s*url\(/assets/rails(-[0-9a-f]+)?.png\)},                       css_output, 'image-url:\s*url\(/assets/rails.png\)'
    assert_match %r{video-path:\s*"/videos/rails(-[0-9a-f]+)?.mp4"},                           css_output, 'video-path:\s*"/videos/rails.mp4"'
    assert_match %r{video-url:\s*url\(/videos/rails(-[0-9a-f]+)?.mp4\)},                       css_output, 'video-url:\s*url\(/videos/rails.mp4\)'
    assert_match %r{audio-path:\s*"/audios/rails(-[0-9a-f]+)?.mp3"},                           css_output, 'audio-path:\s*"/audios/rails.mp3"'
    assert_match %r{audio-url:\s*url\(/audios/rails(-[0-9a-f]+)?.mp3\)},                       css_output, 'audio-url:\s*url\(/audios/rails.mp3\)'
    assert_match %r{font-path:\s*"/fonts/rails(-[0-9a-f]+)?.ttf"},                             css_output, 'font-path:\s*"/fonts/rails.ttf"'
    assert_match %r{font-url:\s*url\(/fonts/rails(-[0-9a-f]+)?.ttf\)},                         css_output, 'font-url:\s*url\(/fonts/rails.ttf\)'
    assert_match %r{font-url-with-query-hash:\s*url\(/fonts/rails(-[0-9a-f]+)?.ttf\?#iefix\)}, css_output, 'font-url:\s*url\(/fonts/rails.ttf?#iefix\)'
    assert_match %r{javascript-path:\s*"/javascripts/rails(-[0-9a-f]+)?.js"},                  css_output, 'javascript-path:\s*"/javascripts/rails.js"'
    assert_match %r{javascript-url:\s*url\(/javascripts/rails(-[0-9a-f]+)?.js\)},              css_output, 'javascript-url:\s*url\(/javascripts/rails.js\)'
    assert_match %r{stylesheet-path:\s*"/stylesheets/rails(-[0-9a-f]+)?.css"},                 css_output, 'stylesheet-path:\s*"/stylesheets/rails.css"'
    assert_match %r{stylesheet-url:\s*url\(/stylesheets/rails(-[0-9a-f]+)?.css\)},             css_output, 'stylesheet-url:\s*url\(/stylesheets/rails.css\)'

    asset_data_url_regexp = %r{asset-data-url:\s*url\((.*?)\)}
    assert_match asset_data_url_regexp, css_output, 'asset-data-url:\s*url\((.*?)\)'
    asset_data_url_match = css_output.match(asset_data_url_regexp)[1]
    asset_data_url_expected = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw%2FeHBhY2tldCBiZWdpbj0i77u%2FIiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8%2BIDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1NzowMSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNS4xIE1hY2ludG9zaCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpCNzY5NDE1QkQ2NkMxMUUwOUUzM0E5Q0E2RTgyQUExQiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpCNzY5NDE1Q0Q2NkMxMUUwOUUzM0E5Q0E2RTgyQUExQiI%2BIDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOkE3MzcyNTQ2RDY2QjExRTA5RTMzQTlDQTZFODJBQTFCIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkI3Njk0MTVBRDY2QzExRTA5RTMzQTlDQTZFODJBQTFCIi8%2BIDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY%2BIDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8%2B0HhJ9AAAABBJREFUeNpi%2BP%2F%2FPwNAgAEACPwC%2FtuiTRYAAAAASUVORK5CYII%3D'
    assert_equal asset_data_url_expected, asset_data_url_match
  end
end
