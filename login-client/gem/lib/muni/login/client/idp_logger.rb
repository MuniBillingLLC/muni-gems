# Identity logger
module Muni
  module Login
    module Client
      class IdpLogger
        MUNI_GEM_VERSION = "0.0.30" # keep in sync with "muni-login-client.gemspec"

        def initialize(idrequest: nil)
          @rails_logger = Rails.logger
          bind(idrequest: idrequest)
        end

        def bind(idrequest:)
          @idrequest = idrequest
        end

        # use this method to dump all kinds of information for troubleshooting
        # never enable this in prod, since traces may contain privileged
        # information
        def trace(message)
          if ENV['MUNIDEV_IDPLOG_TRACE'].present?
            @rails_logger.info decorate(message: message, level: "trace")
          end
        end

        def info(message)
          @rails_logger.info decorate(message: message, level: "info")
        end

        def warn(message)
          @rails_logger.warn decorate(message: message, level: "warn")
        end

        def error(message)
          @rails_logger.error decorate(message: message, level: "error")
        end

        private

        def api_vector
          @idrequest&.api_vector
        end

        def decorate(message:, level:)
          Muni::Login::Client::ToolBox.reject_blanks(
            message: message,
            action_signature: action_signature,
            api_vector: api_vector,
            gem_version: MUNI_GEM_VERSION,
            level: level,
            topic: 'muni_login_client'
          )
        end

        def action_signature
          @idrequest&.action_signature
        end

      end
    end
  end
end
