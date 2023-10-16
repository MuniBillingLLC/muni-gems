module Muni
  module Login
    module Client
      module Wardens
        class VendorWarden < Base
          include ::ActiveSupport::Configurable

          # The secure token format requires API tokens be made of two parts: "[api_key]:[api_secret]". Example:
          #     "DOKSS234957DKR:943HRWELRHERQWE"
          # [api_key] is matched against billing database
          # [api_secret] is matched against runtime configuration
          config_accessor :config_api_secret

          def authorize!
            validate_token!
            secure_identity = create_identity!
            validate_identity!(secure_identity)
            accept_identity(secure_identity)
          end

          private

          def validate_token!
            if api_secret.blank?
              idlog.warn(
                class: self.class.name,
                method: __method__,
                message: "api_secret not provided, please switch to secure token format")
            elsif config_api_secret.blank?
              idlog.warn(
                class: self.class.name,
                method: __method__,
                message: "api_secret not configured, please switch to secure token format")
            elsif api_secret.to_s.strip != config_api_secret.to_s.strip
              raise Muni::Login::Client::Errors::Unauthorized.new(detail: "Invalid api_secret")
            end
          end

          def create_identity!
            Muni::Login::Client::SidCreator
              .new
              .from_api_key(
                realm: ApiUser.to_s,
                api_key: api_key)
          end

          def raise_if_locked(api_user)
            raise Muni::Login::Client::Errors::Forbidden.new(
              error_code: Muni::Login::Client::Errors::Base::ERC_FORBIDDEN_LOCKED
            ) if api_user.locked_at.present?
          end

          def api_token
            idrequest.api_token
          end

          def api_key
            api_token.split(':').first
          end

          def api_secret
            api_token.split(':').second
          end

        end
      end
    end
  end
end
