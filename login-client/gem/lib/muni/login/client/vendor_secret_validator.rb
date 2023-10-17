# validates vendor secrets
module Muni
  module Login
    module Client
      class VendorSecretValidator < Muni::Login::Client::Base
        include ::ActiveSupport::Configurable

        config_accessor :config_csv_secrets

        def is_valid?(secure_identity:, api_secret:)
          if secure_identity.nil?
            idlog.warn(
              class: self.class.name,
              method: __method__,
              message: "secure_identity not provided")
            return false
          end

          # allowing blank secrets provides backward compatibility
          # this will be disabled as soon as we fully adopt secure tokens
          if api_secret.blank?
            idlog.warn(
              class: self.class.name,
              method: __method__,
              message: "api_secret not provided; please switch to secure token format")
            return true
          end

          # at this point we ignore the api_key and just check the secrets array
          all_secrets.include?(api_secret.to_s.strip)
        end

        #a special purpose API secret, for communicating between our own services
        def system_api_secret
          all_secrets.first
        end

        private

        def all_secrets
          @all_secrets ||= self.config_csv_secrets
                               .to_s
                               .split(',')
                               .map { |item| item.strip }
                               .reject { |item| item.blank? }
                               .uniq
                               .sort
        end

      end
    end
  end
end
