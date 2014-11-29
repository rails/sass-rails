require 'test_helper'

class ScaffoldGeneratorTest < Sass::Rails::TestCase
  test "scss files are generated during scaffold generation of scss projects" do
    within_rails_app "scss_project" do
      generate_scaffold
      assert_file_exists "app/assets/stylesheets/foos.scss"
      assert_file_exists "app/assets/stylesheets/scaffolds.scss"
      assert_not_output /conflict/
    end
  end

  test "sass files are generated during scaffold generation of sass projects" do
    within_rails_app "sass_project" do
      generate_scaffold
      assert_file_exists "app/assets/stylesheets/foos.sass"
      assert_file_exists "app/assets/stylesheets/scaffolds.sass"
      assert_not_output /conflict/
    end
  end

  test "scss files are generated during scaffold generation of a engine project, if is called with --stylesheet-engine=scss" do
    within_rails_app "engine_project" do
      generate_scaffold "--stylesheet-engine=scss"
      assert_file_exists "app/assets/stylesheets/engine_project/foos.scss"
      assert_file_exists "app/assets/stylesheets/scaffolds.scss"
      assert_not_output /conflict/
    end
  end

  test "sass files are generated during scaffold generation of a engine project, if is called with --stylesheet-engine=sass" do
    within_rails_app "engine_project" do
      generate_scaffold "--stylesheet-engine=sass"
      assert_file_exists "app/assets/stylesheets/engine_project/foos.sass"
      assert_file_exists "app/assets/stylesheets/scaffolds.sass"
      assert_not_output /conflict/
    end
  end

  # DISABLED because we've removed the feature for now.
  # test "scss template has correct dasherized css class for namespaced controllers" do
  #   within_rails_app "scss_project" do
  #     runcmd "rails generate controller foo/bar"
  #     assert_file_exists "app/assets/stylesheets/foo/bar.scss"
  #     assert_match /\.foo-bar/, File.read("app/assets/stylesheets/foo/bar.scss")
  #   end
  # end
  #
  # test "sass template has correct dasherized css class for namespaced controllers" do
  #   within_rails_app "sass_project" do
  #     runcmd "rails generate controller foo/bar"
  #     assert_file_exists "app/assets/stylesheets/foo/bar.sass"
  #     assert_match /\.foo-bar/, File.read("app/assets/stylesheets/foo/bar.sass")
  #   end
  # end

private

  def generate_scaffold(args = nil)
    runcmd "bundle exec rails generate scaffold foo #{args}"
  end
end
