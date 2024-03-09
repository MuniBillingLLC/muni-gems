module Muni
  module Login
    module Client
      class Base

        WHSP = 32.chr
        DOT_WHSP = ".#{WHSP}".freeze
        AUTHORIZATION_HEADER = "Authorization".freeze

        API_TOKEN_HEADER = "HTTP_X_API_TOKEN".freeze
        API_TOKEN_HEADER_RFC_7230 = "X-API-TOKEN".freeze

        API_CALL_ID_HEADER = "HTTP_X_API_CALL_ID".freeze
        API_CALL_ID_HEADER_RFC_7230 = "X-API-CALL-ID".freeze

        def dal
          @dal ||= Muni::Login::Client::DataAccessLayer.new
        end

      end
    end
  end
end
