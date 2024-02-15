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
              location: "#{self.class.name}.#{__method__}",
              message: "secure_identity not provided")
            return false
          end

          # since version 0.0.14 blank secrets are no longer supported
          # see https://jiramb.atlassian.net/browse/MBMAIN-8328 for details
          if api_secret.blank?
            idlog.warn(
              location: "#{self.class.name}.#{__method__}",
              message: "api_secret not provided; please switch to secure token format")
            return false
          end

          # at this point we ignore the api_key and just check the secrets array
          all_secrets.include?(api_secret.to_s.strip)
        end

        # a special purpose API secret, for communicating between our own services
        # currently this is the only secret being defined
        def system_api_secret
          all_secrets.first
        end

        private

        def all_secrets
          @all_secrets ||= if self.config_csv_secrets.present?
                             self.config_csv_secrets
                                 .to_s
                                 .split(',')
                                 .map { |item| item.strip }
                                 .reject { |item| item.blank? }
                                 .uniq
                                 .sort
                           elsif evar_csv_secrets.present?
                             # you should consider setting config_csv_secrets in an initializer to prevent the gem
                             # reaching out to the evars directly
                             Rails.logger.warn "VendorSecretValidator.config_csv_secrets not set; using value from MUNI_API_SECRETS_CSV"
                             evar_csv_secrets
                               .to_s
                               .split(',')
                               .map { |item| item.strip }
                               .reject { |item| item.blank? }
                               .uniq
                               .sort
                           else
                             # see https://jiramb.atlassian.net/browse/MBMAIN-8328
                             raise Muni::Login::Client::Errors::BadConfiguration.new(
                               detail: "Please set 'config_csv_secrets' to enable secure API tokens")
                           end
        end

        def evar_csv_secrets
          ENV['MUNI_API_SECRETS_CSV']
        end
      end
    end
  end
end
