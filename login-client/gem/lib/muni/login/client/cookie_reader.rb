module Muni
  module Login
    module Client
      class CookieReader

        def initialize(plain_cookies:, top_level_domain: nil)
          @plain_cookies = plain_cookies
          @top_level_domain = top_level_domain
        end

        def sid_token
          plain_cookies[sid_cookie_name]
        end

        # this is somewhat hacky, there should be no deletion method on a pure
        # reader. However, it simplifies some downstream operations, so here we
        # have
        def delete_sid_token
          plain_cookies.delete(sid_cookie_name, domain: top_level_domain)
        end

        private

        attr_reader :plain_cookies, :top_level_domain

        delegate :sid_cookie_name, to: :gem_settings

        def gem_settings
          @gem_settings ||= Muni::Login::Client::Settings.new
        end

      end
    end
  end
end
