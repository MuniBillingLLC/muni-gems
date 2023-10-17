module Muni
  module Login
    module Client
      module Wardens
        class VendorWarden < Base

          def authorize!
            validate_token!
            secure_identity = create_identity!
            validate_identity!(secure_identity)
            accept_identity(secure_identity)
          end

          private

          def validate_identity!(secure_identity)
            super(secure_identity)
            unless vsv.is_valid?(secure_identity: secure_identity, api_secret: api_secret)
              raise Muni::Login::Client::Errors::Unauthorized.new(
                detail: "invalid api_secret")
            end
          end

          def create_identity!
            Muni::Login::Client::SidCreator
              .new
              .from_api_key(
                realm: ApiUser.to_s,
                api_key: api_key)
          end

          # The secure token format requires API tokens be made of two parts: "[api_key]:[api_secret]". Example:
          #     "DOKSS234957DKR:943HRWELRHERQWE"
          # [api_key] is matched against billing database
          # [api_secret] is usually set from environment variable during rails initialization
          def api_token
            idrequest.api_token.to_s
          end

          def api_key
            api_token.split(':').first
          end

          def api_secret
            api_token.split(':').second
          end

          def vsv
            @vsv ||= Muni::Login::Client::VendorSecretValidator.new
          end

        end
      end
    end
  end
end
