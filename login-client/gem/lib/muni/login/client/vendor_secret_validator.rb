# validates vendor secrets
module Muni
  module Login
    module Client
      class VendorSecretValidator < Muni::Login::Client::Base
        include Concerns::BelongsToKeep

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
            all_secrets: api_secrets)

          # at this point we ignore the api_key and just check the secrets array
          api_secrets.include?(api_secret.to_s.strip)
        end

        private

        delegate :api_secrets, to: :gem_settings

        def gem_settings
          @gem_settings ||= Muni::Login::Client::Settings.new
        end

      end
    end
  end
end
