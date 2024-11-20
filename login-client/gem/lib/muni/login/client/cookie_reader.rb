module Muni
  module Login
    module Client
      class CookieReader

        def initialize(plain_cookies:)
          @plain_cookies = plain_cookies
        end

        def sid_token
          plain_cookies[sid_cookie_name]
        end

        private

        attr_reader :plain_cookies

        delegate :sid_cookie_name, to: :gem_settings

        def gem_settings
          @gem_settings ||= Muni::Login::Client::Settings.new
        end

      end
    end
  end
end
