Rails.application.config.assets.configure do |env|
  env.register_postprocessor 'text/css' do |input|
    input[:data].gsub /@import/, 'fail engine'
  end
end
