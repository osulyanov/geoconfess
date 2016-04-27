Apipie.configure do |config|
  config.app_name = 'Geoconfess'
  config.api_base_url = '/api'
  config.doc_base_url = '/apidoc'
  config.reload_controllers = Rails.env.development?
  config.api_controllers_matcher = File.join(Rails.root, 'app', 'controllers', 'api', '**', '**')
  config.api_routes = Rails.application.routes
  config.default_version = 'V1'
  config.validate = true
  config.app_info['V1'] = <<-EOS
    ## OAuth authorisation
    Just send POST request to **/oauth/token** with parameters
    *   grant_type=password
    *   username= User email
    *   password= User password
    *   os= Client OS type: ios or android
    *   push_token= Client push token

    os and push_token attributes are optional.

    In response you'll receive access token and refresh token, like that:
    *   {
    *     "access_token" : "93eea114d283b416e2e9eb152fcb99b46392a1c635ab971753113592b6b8d7cf",
    *     "created_at" : 1455882679,
    *     "refresh_token" : "42ecf7e848c392d89103c90a109d8b1f0fbdf6db16f528f4f7b523aec9217a09",
    *     "token_type" : "bearer"
    *   }
  EOS
  config.default_locale = 'en'
  config.markup = Apipie::Markup::Markdown.new
  config.validate = false
end
