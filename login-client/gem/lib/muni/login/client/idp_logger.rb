# Identity logger
module Muni
  module Login
    module Client
      class IdpLogger
        MUNI_GEM_VERSION = "0.0.18" # keep in sync with "muni-login-client.gemspec"

        def initialize
          @rails_logger = Rails.logger
        end

        def bind(idrequest:)
          @idrequest = idrequest
        end

        def debug(message)
          @rails_logger.debug decorate(message: message, level: "debug")
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

        # use this method to dump all kinds of information for troubleshooting
        # never enable this in prod, since traces may contain privileged
        # information
        def trace(message)
          if ENV['MUNIDEV_IDPLOG_TRACE'].present?
            @rails_logger.info decorate(message: message, level: "trace")
          end
        end

        private

        def decorate(message:, level:)
          msg_hash = {
            level: level,
            gem_version: MUNI_GEM_VERSION,
            message: message
          }
          if @idrequest.present?
            msg_hash[:action] = @idrequest.action_signature
          end

          msg_hash
        end

      end
    end
  end
end
