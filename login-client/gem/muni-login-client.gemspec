Gem::Specification.new do |s|
  s.name = "muni-login-client"
  s.version = "0.0.45" # keep in sync with "lib/muni/login/client/idp_logger.rb"
  s.summary = "Muni Login Client"
  s.description = "Ruby client for Muni Login Service SSO authentication and session management"
  s.authors = ["Muni Billing"]
  s.email = "sales@munibilling.com"
  s.homepage = "https://github.com/MuniBillingLLC"
  s.license = "Nonstandard"
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 3.1.3'

  s.add_dependency "activesupport", '>= 6.1', '< 8'
  s.add_dependency "activerecord", '>= 6.1', '< 8'
  s.add_dependency "actionpack", '>= 6.1', '< 8'
  s.add_dependency "jwt", '>= 2.3.0'

  s.add_development_dependency 'rails', '>= 6.1', '< 8'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.12', '>= 3.12.0'
  s.add_development_dependency 'rspec-rails', '~> 5.0'
  s.add_development_dependency 'sqlite3', '~> 1.4', '>= 1.4.4'
  s.add_development_dependency 'faker', '~> 2.0'
  s.add_development_dependency 'factory_bot_rails', '~> 5.2', '>= 5.2.0'
  s.add_development_dependency 'climate_control', '~> 0.2.0'

  s.files = [
    "LICENSE",
    "README.md",
    "lib/muni-login-client.rb",

    "lib/muni/login/client/concerns/belongs_to_keep.rb",
    "lib/muni/login/client/concerns/belongs_to_request.rb",

    "lib/muni/login/client/errors/base.rb",
    "lib/muni/login/client/errors/bad_configuration.rb",
    "lib/muni/login/client/errors/bad_gateway.rb",
    "lib/muni/login/client/errors/forbidden.rb",
    "lib/muni/login/client/errors/malformed_identity.rb",
    "lib/muni/login/client/errors/unauthorized.rb",

    "lib/muni/login/client/ref_tokens/builder.rb",
    "lib/muni/login/client/ref_tokens/cipher.rb",
    "lib/muni/login/client/ref_tokens/parser.rb",

    "lib/muni/login/client/wardens/abstract_warden.rb",
    "lib/muni/login/client/wardens/sid_warden.rb",
    "lib/muni/login/client/wardens/vendor_warden.rb",

    "lib/muni/login/client/base.rb",
    "lib/muni/login/client/cookie_reader.rb",
    "lib/muni/login/client/data_access_layer.rb",
    "lib/muni/login/client/idp_cache.rb",
    "lib/muni/login/client/idp_keep.rb",
    "lib/muni/login/client/idp_logger.rb",
    "lib/muni/login/client/idp_request.rb",
    "lib/muni/login/client/json_proxy.rb",
    "lib/muni/login/client/jwt_decoder.rb",
    "lib/muni/login/client/service_locator.rb",
    "lib/muni/login/client/service_proxy.rb",
    "lib/muni/login/client/settings.rb",
    "lib/muni/login/client/sid_creator.rb",
    "lib/muni/login/client/sid_validator.rb",
    "lib/muni/login/client/tool_box.rb",
    "lib/muni/login/client/uri_group.rb",
    "lib/muni/login/client/vendor_creator.rb",
    "lib/muni/login/client/vendor_secret_validator.rb"
  ]
end

