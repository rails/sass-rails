
class SassRailsTestPostProcessor
  def initialize(filename, &block)
    @filename = filename
    @source   = block.call
  end

  def render(context, _)
    self.class.run(@source)
  end

  def self.run(source)
    source.gsub /@import/, 'fail engine'
  end

  def self.call(input)
    source = input[:data]
    result = run(source)
    { data: result }
  end
end

Rails.application.config.assets.configure do |env|
  env.register_postprocessor 'text/css', SassRailsTestPostProcessor
end
