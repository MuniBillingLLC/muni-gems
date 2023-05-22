module Muni
  module Login
    module Client
      module Wardens
        class Base < Muni::Login::Client::Base

          def initialize(idrequest:, idkeep:)
            super()
            @idrequest = idrequest
            @idkeep = idkeep
          end

          private

          attr_reader :idkeep, :idrequest

          def accept_identity(secure_identity)
            idkeep.sid = secure_identity.sid

            idlog.debug(
              class: self.class.name,
              method: __method__,
              sid: secure_identity.sid,
              message: "Authorized")
          end

          def validate_identity!(secure_identity)
            get_validator(secure_identity).validate!
          end

          def get_validator(secure_identity)
            if secure_identity.nil?
              raise Muni::Login::Client::Errors::MalformedIdentity.new(
                detail: "Missing identity")
            end

            Muni::Login::Client::SidValidator
              .new(secure_identity: secure_identity)
          end

        end
      end
    end
  end
end
