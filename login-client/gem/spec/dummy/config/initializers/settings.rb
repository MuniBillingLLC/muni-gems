Muni::Login::Client::Settings.configure do |config|
  # OPTIONAL
  # Our application name in the muni universe. You may see this in the logs and some
  # error messages. Also used to derive the redis bucket name (e.g. "spec_app.login-client")
  config.idpc_app_name = "spec_app"

  # List of login service locations
  config.login_service_url_list = "http://test1.munidev.local,http://test2.munidev.local"
end

