# validates vendor secrets
module Muni
  module Login
    module Client
      class VendorSecretValidator < Muni::Login::Client::Base
        include ::ActiveSupport::Configurable
        include Concerns::BelongsToKeep

        config_accessor :config_csv_secrets

        def initialize(idkeep:)
          @idkeep = idkeep
        end

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

          idlog.trace(
            location: "#{self.class.name}.#{__method__}",
            message: "Matching against all secrets",
            api_secret: api_secret.to_s.strip,
            all_secrets: all_secrets)

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
                             idlog.trace(
                               location: "#{self.class.name}.#{__method__}",
                               config_csv_secrets: self.config_csv_secrets)

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

                             idlog.trace(
                               location: "#{self.class.name}.#{__method__}",
                               evar_csv_secrets: evar_csv_secrets)

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
