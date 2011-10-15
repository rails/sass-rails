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

## Important Note

Sprockets provides some directives that are placed inside of comments called `require`, `require_tree`, and
`require_self`. **<span style="color:#c00">DO NOT USE THEM IN YOUR SASS/SCSS FILES.</span>** They are very 
primitive and do not work well with Sass files. Instead, use Sass's native `@import` directive which
`sass-rails` has customized to integrate with the conventions of your rails projects.

### Options

The [list of supported options](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#options) can be found on the Sass Website with the following  caveats:

1. Output compression is now controlled via the `config.assets.compress` boolean option instead of through the `:style` option.
2. `:never_update` - This option is not supported. Instead set `config.assets.enabled = false`
3. `:always_update` - This option is not supported. Sprockets uses a controller to access stylesheets in development mode instead of a full scan for changed files.
4. `:always_check` - This option is not supported. Sprockets always checks in development.
5. `:syntax` - This is determined by the file's extensions.
6. `:filename` - This is determined by the file's name.
7. `:line` - This is provided by the template handler.

## Features

* **Glob Imports**. When in rails, there is a special import syntax that allows you to
  glob imports relative to the folder of the stylesheet that is doing the importing.
  E.g. `@import "mixins/*"` will import all the files in the mixins folder and
  `@import "mixins/**/*"` will import all the files in the mixins tree.
  Any valid ruby glob may be used. The imports are sorted alphabetically.
  **NOTE:** It is recommended that you only use this when importing pure library
  files (containing mixins and variables) because it is difficult to control the
  cascade ordering for imports that contain styles using this approach.

* **Asset Helpers**. When using the asset pipeline, paths to assets must be rewritten.
  When referencing assets use the following asset helpers:

  * `asset_path($relative-asset-path, $asset-class)` - Returns a string to the asset.
    For example: `asset_path("rails.png", image)` becomes `"/assets/rails.png"`
  * `asset_url($relative-asset-path, $asset-class)` - Returns url reference to the asset.
    
    For example: `asset_url("rails.png", image)` becomes `url(/assets/rails.png)`
  * As a convenience, for each of the following asset classes there are
    corresponding `_path` and `_url` helpers:
    image, font, video, audio, javascript, stylesheet.
    
    For example: `image_url("rails.png")` becomes `url(/assets/rails.png)` and
    `image_path("rails.png")` becomes `"/assets/rails.png"`.
  
  * `asset_data_url($relative-asset-path)` - Returns url reference to the Base64-encoded asset at the specified path.
    For example: `asset-data-url("rails.png")` becomes `url(data:image/png;base64,iVBORw0K...)`

## Running Tests

    $ bundle install
    $ bundle exec rake test

If you need to test against local gems, use Bundler's gem :path option in the Gemfile and also edit `test/support/test_helper.rb` and tell the tests where the gem is checked out.
