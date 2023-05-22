module Muni
  module Login
    module Client
      class SidValidator

        def initialize(secure_identity:)
          @secure_identity = secure_identity
        end

        def validate!
          ensure_unlocked_identity!
        end

        private

        attr_reader :secure_identity

        def ensure_unlocked_identity!
          if secure_identity.locked_at.present?
            raise Muni::Login::Client::Errors::Forbidden.new(
              error_code: Muni::Login::Client::Errors::Base::ERC_FORBIDDEN_LOCKED)
          end
        end
      end
    end
  end
end

