module Muni
  module Login
    module Client
      class CookieReader

        SID_TOKEN = "sid_token".freeze

        def initialize(plain_cookies:)
          @plain_cookies = plain_cookies
        end

        def sid_token
          @plain_cookies[SID_TOKEN]
        end

        private

      end
    end
  end
end
