require 'fileutils'
require 'tmpdir'

class Sass::Rails::TestCase < ActiveSupport::TestCase

  class ExecutionError < StandardError
    attr_accessor :output
    def initialize(message, output = nil)
      super(message)
      self.output = output
    end
    def message
      "#{super}\nOutput was:\n#{output}"
    end
  end

  module SilentError
    attr_accessor :output
    def message
      "#{super}\nOutput was:\n#{output}"
    end
  end

  protected

  def fixture_path(path)
    File.expand_path("../../fixtures/#{path}", __FILE__)
  end

  module TestAssetPaths
    attr_accessor :assets
  end

  def sprockets_render(project, filename)
    env = Sprockets::Environment.new
    env.context_class.class_eval do
      def self.assets=(assets)
        @assets = assets
      end
      def self.assets
        @assets
      end
      def self.sass_config
        Sass::Rails::Railtie.config.sass
      end
      def config
        @config ||= ActiveSupport::InheritableOptions.new
      end
      include Sprockets::Helpers::RailsHelper
      def asset_paths_with_testing
        paths = asset_paths_without_testing
        unless paths.is_a?(TestAssetPaths)
          paths.extend(TestAssetPaths)
          paths.assets = self.class.assets
        end
        paths
      end
      alias_method_chain :asset_paths, :testing
    end
    env.context_class.assets = env
    env.paths << fixture_path("#{project}/app/assets/stylesheets")
    env[filename].to_s
  end

  def assert_file_exists(filename)
    assert File.exists?(filename), "could not find #{filename}. PWD=#{Dir.pwd}\nDid find: #{Dir.glob(File.dirname(filename)+"/*").join(", ")}"
  end

  def assert_not_output(match)
    assert_no_match match, $last_ouput
  end

  def assert_output(match)
    assert $last_ouput.to_s =~ match, "#{match} was not found in #{$last_ouput.inspect}"
  end

  # Copies a rails app fixture to a temp directory
  # and changes to that directory during the yield.
  #
  # Automatically changes back to the working directory
  # and removes the temp directory when done.
  def within_rails_app(name, without_gems = [], gem_locations = $gem_locations)
    sourcedir = File.expand_path("../../fixtures/#{name}", __FILE__)
    Dir.mktmpdir do |tmpdir|
      FileUtils.cp_r "#{sourcedir}/.", tmpdir
      Dir.chdir(tmpdir) do
        gem_locations.each {|name, path| modify_gem_location name, path}
        without_gems.each {|name| remove_gem name}
        runcmd "bundle install --verbose"
        yield
      end
    end
  end

  def process_gemfile(gemfile = "Gemfile", &blk)
    gem_contents = File.readlines(gemfile)
    gem_contents.map!(&blk)
    gem_contents.compact!
    File.open(gemfile, "w") do |f|
      f.print(gem_contents.join(""))
    end
  end

  def modify_gem_location(gemname, path, gemfile = "Gemfile")
    found = false
    process_gemfile(gemfile) do |line|
      if line =~ /gem *(["'])#{Regexp.escape(gemname)}\1/
        found = true
        %Q{gem "#{gemname}", :path => #{path.inspect}\n}
      else
        line
      end
    end
    unless found
      File.open(gemfile, "a") do |f|
        f.print(%Q{\ngem "#{gemname}", :path => #{path.inspect}\n})
      end
    end
  end

  def remove_gem(gemname)
    process_gemfile(gemfile) do |line|
      line unless line =~ /gem *(["'])#{Regexp.escape(gemname)}\1/
    end
  end

  def silently
    output = StringIO.new
    $stderr, old_stderr = output, $stderr
    $stdout, old_stdout = output, $stdout
    begin
      yield
    rescue ExecutionError => e
      raise
    rescue => e
      e.extend(SilentError)
      e.output = output.string
      raise
    end
  ensure
    $stderr = old_stderr
    $stdout = old_stdout
  end

  # executes a system command
  # raises an error if it does not complete successfully
  # returns the output as a string if it does complete successfully
  def runcmd(cmd, working_directory = Dir.pwd, clean_env = true, gemfile = "Gemfile", env = {})
    # There's a bug in bundler where with_clean_env doesn't clear out the BUNDLE_GEMFILE environment setting
    # https://github.com/carlhuda/bundler/issues/1133
    env["BUNDLE_GEMFILE"] = "#{working_directory}/#{gemfile}" if clean_env
    todo = Proc.new do
      r, w = IO.pipe
      pid = Kernel.spawn(env, cmd, :out =>w , :err => w, :chdir => working_directory)
      w.close
      Process.wait
      output = r.read
      r.close
      unless $?.exitstatus == 0
        raise ExecutionError, "Command failed with exit status #{$?.exitstatus}: #{cmd}", output
      end
      $last_ouput = output
    end
    if clean_env
      Bundler.with_clean_env(&todo)
    else
      todo.call
    end
  end

end
