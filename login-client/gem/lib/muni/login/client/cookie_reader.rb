module Muni
  module Login
    module Client
      class CookieReader
        include ::ActiveSupport::Configurable

        config_accessor :config_sid_cookie_name

        def initialize(plain_cookies:)
          @plain_cookies = plain_cookies
        end

        def sid_token
          @plain_cookies[sid_cookie_name]
        end

        def sid_cookie_name
          self.config_sid_cookie_name || ENV['MUNI_SID_COOKIE_NAME']
        end

      end
    end
  end
end
