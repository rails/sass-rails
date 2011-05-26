# Official Ruby-on-Rails Integration with Sass

This gem provides official integration for ruby on rails projects with the Sass stylesheet language.

## Installing

Since rails 3.1, new rails projects will be already configured to use Sass. If you are upgrading to rails 3.1 you will need to add the following to your Gemfile:

    gem 'sass-rails'

## Configuration

To configure Sass via rails set use `config.sass` in your
application and/or environment files to set configuration
properties that will be passed to Sass.

### Example

    MyProject::Application.configure do
      config.sass.line_comments = false
      config.sass.syntax = :nested
    end

### Options

The [list of supported options](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#options) can be found on the Sass Website with the following  caveats:

1. Output compression is now controlled via the `config.assets.compress` boolean option instead of through the `:style` option.
2. `:never_update` - This option is not supported. Instead set `config.assets.enabled = false`
3. `:always_update` - This option is not supported. Sprockets uses a controller to access stylesheets in development mode instead of a full scan for changed files.
4. `:always_check` - This option is not supported. Sprockets always checks in development.
5. `:syntax` - This is determined by the file's extensions.
6. `:filename` - This is determined by the file's name.
7. `:line` - This is provided by the template handler.