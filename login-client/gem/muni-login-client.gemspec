Gem::Specification.new do |s|
  s.name = "muni-login-client"
  s.version = "0.0.24" # keep in sync with "lib/muni/login/client/idp_logger.rb"
  s.summary = "Muni Login Client"
  s.description = "Muni Login Client"
  s.authors = ["Muni Billing"]
  s.email = "sales@munibilling.com"
  s.homepage = "https://github.com/MuniBillingLLC"
  s.license = "Nonstandard"
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", '>= 5.2.8'
  s.add_dependency "activerecord", '>= 5.2.8'
  s.add_dependency "actionpack", '>= 5.2.8'
  s.add_dependency "jwt", '>= 2.3.0'

  s.add_development_dependency 'rails', '>= 5.2.8'
  s.add_development_dependency 'rake', '>= 13.0.6'
  s.add_development_dependency 'rspec', '>= 3.12.0'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3', '>= 1.4.4'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'factory_bot_rails', '>= 5.2.0'
  s.add_development_dependency 'nokogiri', '>= 1.10.10'

  # added this to work around "uninitialized constant Nokogiri::HTML4"
  # per https://www.ruby-forum.com/t/i-am-using-ruby-version-2-3-8-and-rails-version-5-2-6-to-develop-my-application-since-yesterday-i-am-getting-the-error-i-tried-to-find-the-occurrence-of-this-nokogiri-html4-in-my-application-but-i-didnt-find-any-of-the-occurrence-like-this/263852
  s.add_development_dependency 'loofah', '~>2.19.1'

  s.files = [
    "LICENSE",
    "README.md",
    "lib/muni-login-client.rb",

    "lib/muni/login/client/concerns/belongs_to_keep.rb",
    "lib/muni/login/client/concerns/belongs_to_request.rb",

    "lib/muni/login/client/errors/base.rb",
    "lib/muni/login/client/errors/bad_gateway.rb",
    "lib/muni/login/client/errors/forbidden.rb",
    "lib/muni/login/client/errors/malformed_identity.rb",
    "lib/muni/login/client/errors/unauthorized.rb",

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
    "lib/muni/login/client/sid_validator.rb",
    "lib/muni/login/client/tool_box.rb",
    "lib/muni/login/client/uri_group.rb",
    "lib/muni/login/client/vendor_creator.rb",
    "lib/muni/login/client/vendor_secret_validator.rb"
  ]
end

