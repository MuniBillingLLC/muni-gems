Muni::Login::Client::IdpCache.configure do |config|
  # OPTIONAL
  # Our application name in the muni universe. You may see this in the logs and some
  # error messages. Example:
  #         APP_NAME=core-login
  # ..among other tings it impacts the naming or redis buckets
  config.config_app_name = "spec_app"

  # OPTIONAL
  # Use this to namespace redis buckets. Example:
  #         REDIS_NAMESPACE=rails_upgrade
  # ... it impacts the naming or redis buckets
  config.config_redis_bucket =  "spec_bucket"

  # HARDCODED
  # Controls default cache expiration
  config.config_retention = 5.minutes
end


