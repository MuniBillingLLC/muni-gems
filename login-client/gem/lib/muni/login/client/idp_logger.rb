# Identity logger
module Muni
  module Login
    module Client
      class IdpLogger

        def initialize
          @rails_logger = Rails.logger
        end

        def bind(idrequest:)
          @idrequest = idrequest
        end

        def debug(message)
          @rails_logger.debug decorate(message)
        end

        def info(message)
          @rails_logger.info decorate(message)
        end

        def warn(message)
          @rails_logger.warn decorate(message)
        end

        def error(message)
          @rails_logger.error decorate(message)
        end

        # use this method to dump all kinds of information for troubleshooting
        # never enable this in prod, since traces may contain privileged
        # information
        def trace(message)
          info("***TRACE: #{message}") if ENV['MUNIDEV_IDPLOG_TRACE'].present?
        end

        private

        def decorate(message)
          return if message.nil?
          return message unless @idrequest.present?
          return message unless message.is_a?(Hash)
          message.merge(action: @idrequest.action_signature)
        end

      end
    end
  end
end
