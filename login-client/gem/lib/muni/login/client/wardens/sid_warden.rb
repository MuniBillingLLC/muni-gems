module Muni
  module Login
    module Client
      module Wardens
        class SidWarden < Base

          def authorize!
            idkeep.set_property(:sid_token, sid_token)
            idkeep.set_property(:decoded_token, decoded_token)
            authenticate_sid_token!
            secure_session = dal.find_secure_identity_by_sid(decoded_token[:sub])
            validate_identity!(secure_session)
            accept_identity(secure_session)
          end

          private

          def authenticate_sid_token!
            dal.authenticate_sid_token!(
              sid_token: sid_token,
              decoded_token: decoded_token,
              loxy: loxy)
          end

          def decoded_token
            Muni::Login::Client::JwtDecoder.new(sid_token).jwt_decode
          rescue StandardError => e
            idlog.info(
              class: self.class.name,
              method: __method__,
              sid_token: sid_token,
              message: e.message)
            raise Muni::Login::Client::Errors::MalformedIdentity.new(detail: "Invalid token")
          end

          def loxy
            @loxy ||= Muni::Login::Client::ServiceProxy.new
          end

          def sid_token
            idrequest.sid_token
          end

        end
      end
    end
  end
end
