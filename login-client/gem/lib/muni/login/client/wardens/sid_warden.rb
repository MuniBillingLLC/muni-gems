module Muni
  module Login
    module Client
      module Wardens
        class SidWarden < AbstractWarden

          def authorize!
            idkeep.set_property(:sid_token, sid_token)
            idkeep.set_property(:decoded_token, decoded_token)
            authenticate_sid_token!
            secure_identity = dal.find_secure_identity_by_sid(decoded_token[:sub])
            validate_identity!(secure_identity)
            accept_identity(secure_identity)
          end

          private

          def authenticate_sid_token!
            if Time.now.to_i > token_expiration
              raise Muni::Login::Client::Errors::MalformedIdentity.new(detail: "Expired token")
            end

            dal.authenticate_sid_token!(
              sid_token: sid_token,
              decoded_token: decoded_token,
              service_proxy: service_proxy)
          end

          def decoded_token
            @decoded_token ||= Muni::Login::Client::JwtDecoder.new(sid_token).jwt_decode
          rescue StandardError => e
            idlog.info(
              location: "#{self.class.name}.#{__method__}",
              sid_token: sid_token,
              message: e.message)
            raise Muni::Login::Client::Errors::MalformedIdentity.new(detail: "Invalid token")
          end

          def token_expiration
            decoded_token[:exp].to_i
          end

          def service_proxy
            @service_proxy ||= Muni::Login::Client::ServiceProxy.new(json_proxy: json_proxy, idlog: idlog)
          end

          def json_proxy
            @json_proxy ||= Muni::Login::Client::JsonProxy.new(base_headers: base_headers)
          end

          def sid_token
            idrequest.sid_token
          end

          def base_headers
            {
              "#{API_VECTOR_HEADER_RFC_7230}" => idrequest.api_vector
            }
          end

        end
      end
    end
  end
end
