Rails.application.config.assets.configure do |env|
  env.register_postprocessor 'text/css', :postprocessor do |context, css|
    css.gsub /@import/, 'fail engine'
  end
end
