module Muni
  module Login
    module Client
      class ServiceProxy < Muni::Login::Client::Base

        def self.build_from_request(idrequest:)
          json_proxy = Muni::Login::Client::JsonProxy.new(
            base_headers: { "#{API_VECTOR_HEADER_RFC_7230}" => idrequest.api_vector })
          idlog = Muni::Login::Client::IdpLogger.new(
            idrequest: idrequest)
          new(json_proxy: json_proxy, idlog: idlog)
        end

        def initialize(json_proxy:, idlog:)
          @idlog = idlog
          @json_proxy = json_proxy
          @idp_locator = Muni::Login::Client::ServiceLocator.new(json_proxy: json_proxy, idlog: idlog)
        end

        # Use this method to check the status of the login service
        def check_status(depth: 'small')
          result = []
          # because of service aliasing, we may have multiple checkpoints
          # per service. Here we check them all
          checkpoints(depth: depth).each do |cp|
            result << { cp[:index] => get_json(uri: cp[:value]) }
          end
          result
        end

        def authenticate_sid_token!(sid_token:, sid:, issuer_url:)
          idp_uri = fetch_first_healthy(issuer_url: issuer_url)
          idlog.trace(
            location: "#{self.class.name}.#{__method__}",
            issuer_url: issuer_url,
            idp_uri: idp_uri.to_s,
            message: "Resolved")

          idp_response = get_idp_response(sid_token: sid_token, idp_uri: idp_uri)
          idlog.trace(
            location: "#{self.class.name}.#{__method__}",
            idp_response: idp_response.except(:payload),
            message: "Received")

          validate_idp_response!(sid: sid, idp_response: idp_response)
          idlog.info(
            location: "#{self.class.name}.#{__method__}",
            sid: sid,
            idp_uri: idp_uri.to_s,
            message: "Authenticated")
        end

        private

        attr_reader :json_proxy, :idlog, :idp_locator

        delegate :get_json, to: :json_proxy

        delegate :service_aliases, :checkpoint_uri, to: :idp_locator

        def validate_idp_response!(sid:, idp_response:)
          if idp_response[:code] != 200
            raise Muni::Login::Client::Errors::Unauthorized.new(
              error_code: Muni::Login::Client::Errors::Base::ERC_IDP_DECLINED,
              detail: "IDP responded with #{idp_response[:code]}")
          end
          if sid != idp_response.dig(:payload, :sid)
            raise Muni::Login::Client::Errors::Unauthorized.new(
              error_code: Muni::Login::Client::Errors::Base::ERC_IDP_DECLINED,
              detail: "IDP SID mismatch")
          end

        end

        def get_idp_response(sid_token:, idp_uri:)
          validation_uri = URI.join(idp_uri, 'api/v2/secure_sessions/validate')
          get_json(
            uri: validation_uri,
            headers: { AUTHORIZATION_HEADER => "Bearer #{sid_token}" })
        end

        def fetch_first_healthy(issuer_url:)
          idp_uri = idp_locator.fetch_first_healthy(URI.parse(issuer_url))
          raise Muni::Login::Client::Errors::BadGateway.new(
            error_code: Muni::Login::Client::Errors::Base::ERC_IDP_NOT_REACHEABLE
          ) if idp_uri.nil?
          idp_uri
        end

        def checkpoints(depth:)
          result = []
          case depth
          when 'small'
            service_aliases.members.each_with_index do |uri, index|
              result << { index: index, value: checkpoint_uri(base_uri: uri, depth: depth) }
            end
          when 'medium'
            service_aliases.members.each_with_index do |uri, index|
              result << { index: index, value: checkpoint_uri(base_uri: uri, depth: depth) }
            end
          end
          result
        end

      end
    end
  end
end
