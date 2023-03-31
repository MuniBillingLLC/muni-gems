module Muni
  module Login
    module Client
      class IdpRequest < Muni::Login::Client::Base

        attr_reader :controller_path, :action_name

        def initialize(controller_path:, action_name:, cookie_reader: nil, http_headers: nil)
          super()
          idlog.bind(idrequest: self)
          @controller_path = controller_path
          @action_name = action_name
          @cookie_reader = cookie_reader
          @http_headers = http_headers
        end

        def api_token
          @http_headers.present? ? @http_headers[API_TOKEN_HEADER] : nil
        end

        def sid_token
          @sid_token ||= sid_token_from_cookies || sid_token_from_headers
        end

        def action_signature
          "#{@controller_path}|#{@action_name}"
        end

        private

        def sid_token_from_cookies
          @cookie_reader&.sid_token
        end

        def sid_token_from_headers
          @http_headers.present? ? @http_headers[AUTHORIZATION_HEADER].to_s.split(WHSP).last : nil
        end

      end
    end
  end
end
