module Muni
  module Login
    module Client
      class Base

        WHSP = 32.chr
        DOT_WHSP = ".#{WHSP}".freeze
        AUTHORIZATION_HEADER = "Authorization".freeze
        API_TOKEN_HEADER = "HTTP_X_API_TOKEN".freeze
        API_TOKEN_HEADER_RFC_7230 = "X-API-TOKEN".freeze

        attr_reader :idlog, :dal

        def initialize
          @idlog = Muni::Login::Client::IdpLogger.new
          @dal = Muni::Login::Client::DataAccessLayer.new
        end

      end
    end
  end
end
