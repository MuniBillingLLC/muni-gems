module Muni
  module Login
    module Client
      module Validators
        class ReferenceValidator < SidValidator

          def validate!
            super()
            ensure_unlocked_reference!
          end

          private

          def reference
            dal.find_user_by_id(secure_identity.mod_id)
          end

          def ensure_unlocked_reference!
            if reference.locked_at.present?
              raise Muni::Login::Client::Errors::Forbidden.new(
                error_code: Muni::Login::Client::Errors::Base::ERC_FORBIDDEN_LOCKED)
            end
          end

        end
      end
    end
  end
end
