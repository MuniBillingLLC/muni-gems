module Muni
  module Login
    module Client
      module Wardens
        class VendorWarden < Base
          include ::ActiveSupport::Configurable

          config_accessor :config_api_secret

          def authorize!
            validate_token!
            secure_identity = create_identity!
            validate_identity!(secure_identity)
            accept_identity(secure_identity)
          end

          private

          def validate_token!
            if api_token.blank?
              raise Muni::Login::Client::Errors::Unauthorized.new(detail: "Invalid api_token; Expecting 'api_key:api_secret'")
            elsif api_key.blank?
              raise Muni::Login::Client::Errors::Unauthorized.new(detail: "Invalid api_key")
            elsif api_secret.blank?
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

        end
      end
    end
  end
end
