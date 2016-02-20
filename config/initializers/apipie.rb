Apipie.configure do |config|
  config.app_name = 'Geoconfess'
  config.api_base_url = '/api'
  config.doc_base_url = '/apidoc'
  config.reload_controllers = Rails.env.development?
  config.api_controllers_matcher = File.join(Rails.root, 'app', 'controllers', 'api', '**', '**')
  config.api_routes = Rails.application.routes
  config.default_version = '1'
  config.validate = true
  # config.app_info['1'] = 'Add description…'
  config.default_locale = 'en'
  config.markup = Apipie::Markup::Markdown.new
end
