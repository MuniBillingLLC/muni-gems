module Muni
  module Login
    module Client
      class CookieWriter

        def initialize(plain_cookies:, cookie_jar:, cookie_domain: nil)
          @plain_cookies = plain_cookies
          @cookie_jar = cookie_jar
          @cookie_domain = cookie_domain
        end

        def set_sid_token(value)
          if value.blank?
            delete_sid_token
          elsif sid_token != value
            plain_cookies[sid_cookie_name] = sid_token_hash(value)
          end
        end

        private

        attr_reader :plain_cookies, :cookie_jar, :cookie_domain

        delegate :sid_cookie_name, :sid_cookie_duration, to: :gem_settings

        def sid_token
          plain_cookies[sid_cookie_name]
        end

        def delete_sid_token
          cookie_jar.delete(sid_cookie_name, domain: cookie_domain)
        end

        def sid_token_hash(value)
          Muni::Login::Client::ToolBox.reject_blanks(
            value: value,
            path: '/',
            expires: sid_cookie_duration,
            domain: cookie_domain,
            same_site: :strict
          )
        end

        def gem_settings
          @gem_settings ||= Muni::Login::Client::Settings.new
        end

      end
    end
  end
end
