module Muni
  module Login
    module Client
      module Wardens
        class VendorWarden < Base

          def authorize!
            secure_identity = create_identity!
            validate_identity!(secure_identity)
            accept_identity(secure_identity)
          end

          private

          def create_identity!
            Muni::Login::Client::SidCreator
              .new
              .from_secret_token!(
                realm: ApiUser.to_s,
                secret_token: api_token)
          end

          def raise_if_locked(api_user)
            raise Muni::Login::Client::Errors::Forbidden.new(
              error_code: Muni::Login::Client::Errors::Base::ERC_FORBIDDEN_LOCKED
            ) if api_user.locked_at.present?
          end

          def api_token
            idrequest.api_token
          end

        end
      end
    end
  end
end
