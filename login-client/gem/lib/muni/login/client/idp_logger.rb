# Identity logger
module Muni
  module Login
    module Client
      class IdpLogger
        MUNI_GEM_VERSION = "0.0.40" # keep in sync with "muni-login-client.gemspec"

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
          if log_trace_enabled?
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

        delegate :log_trace_enabled?, to: :gem_settings

        def api_vector
          @idrequest&.api_vector
        end

        def decorate(message:, level:)
          location = if message.is_a?(Hash)
                       message[:location]
                     end
          message2 = if message.is_a?(Hash)
                       message.except(:location)
                     else
                       message
                     end

          Muni::Login::Client::ToolBox.reject_blanks(
            level: level,
            location: location,
            message: message2,
            action_signature: action_signature,
            api_vector: api_vector,
            gem_version: MUNI_GEM_VERSION,
            topic: 'muni_login_client'
          )
        end

        def action_signature
          @idrequest&.action_signature
        end

        def gem_settings
          @gem_settings ||= Muni::Login::Client::Settings.new
        end

      end
    end
  end
end
