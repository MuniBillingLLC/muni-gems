Muni::Login::Client::Settings.configure do |config|
  # OPTIONAL
  # Our application name in the muni universe. You may see this in the logs and some
  # error messages. Example:
  #         APP_NAME=core-login
  # ..among other tings it impacts the naming or redis buckets
  config.idpc_app_name = "spec_app"

  # OPTIONAL
  # Use this to namespace redis buckets. Example:
  #         REDIS_NAMESPACE=rails_upgrade
  # ... it impacts the naming or redis buckets
  config.idpc_redis_bucket =  "spec_bucket"

  # HARDCODED
  # Controls default cache expiration
  config.idpc_retention = 5.minutes

  # List of login service locations
  config.login_service_url_list = "http://test1.munidev.local,http://test2.munidev.local"
end

