Gem::Specification.new do |s|
  s.name        = "muni-login-client"
  s.version     = "0.0.2"
  s.summary     = "Muni Login Client"
  s.description = "Muni Login Client"
  s.authors     = ["Muni Billing"]
  s.email       = "sales@munibilling.com"
  s.homepage    = "https://github.com/MuniBillingLLC"
  s.license     = "Nonstandard"
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", '>= 5.2.8'
  s.add_dependency "activerecord", '>= 5.2.8'
  s.add_dependency "jwt", '>= 2.3.0'

  s.add_development_dependency 'rails', '>= 5.2.8'
  s.add_development_dependency 'rake', '>= 13.0.6'
  s.add_development_dependency 'rspec', '>= 3.12.0'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3', '>= 1.4.4'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'factory_bot_rails', '>= 5.2.0'
  s.add_development_dependency 'nokogiri', '>= 1.10.10'

  s.files = [
    "LICENSE",
    "README.md",
    "lib/muni-login-client.rb",

    "lib/muni/login/client/errors/base.rb",
    "lib/muni/login/client/errors/bad_gateway.rb",
    "lib/muni/login/client/errors/forbidden.rb",
    "lib/muni/login/client/errors/malformed_identity.rb",
    "lib/muni/login/client/errors/unauthorized.rb",

    "lib/muni/login/client/validators/base.rb",
    "lib/muni/login/client/validators/sid_validator.rb",
    "lib/muni/login/client/validators/reference_validator.rb",

    "lib/muni/login/client/wardens/base.rb",
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
    "lib/muni/login/client/sid_creator.rb",
    "lib/muni/login/client/tool_box.rb",
    "lib/muni/login/client/uri_group.rb"
  ]
end

