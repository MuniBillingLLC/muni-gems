module Muni
  module Login
    module Client
      class IdpKeep < Base

        def initialize(secure_identity: nil)
          super()
          @properties = {}
          self.sid = secure_identity&.sid
        end

        def clear
          idlog.info(
            class: self.class.name,
            method: __method__,
            sid: sid)

          @properties.clear
        end

        def admin
          return nil unless secure_identity&.mod_name == Admin.to_s

          dal.find_admin_by_id(secure_identity&.mod_id)
        end

        def user
          return nil unless secure_identity&.mod_name == User.to_s

          dal.find_user_by_id(secure_identity&.mod_id)
        end

        def api_user
          return nil unless secure_identity&.mod_name == ApiUser.to_s

          dal.find_api_user_by_id(secure_identity&.mod_id)
        end

        # a special purpose API token, for communicating between our own services
        def system_api_token
          @system_api_token ||= [
            system_api_user&.api_key,
            vsv.system_api_secret
          ].join(':')
        end

        def customer
          return nil unless secure_identity&.mod_name == Customer.to_s

          dal.find_customer_by_id(secure_identity&.mod_id)
        end

        def set_property(key, value)
          @properties[key] = value
        end

        def sid
          @properties[:sid]
        end

        def sid=(value)
          @properties[:sid] = value
        end

        def secure_identity
          dal.find_secure_identity_by_sid(sid)
        end

        def sid_token
          @properties[:sid_token]
        end

        def decoded_token
          @properties[:decoded_token]
        end

        private

        # a special purpose API user, for communicating between our own services
        def system_api_user
          @system_api_user ||= ApiUser.where("api_key like 'SYSTEM_%'").first || ApiUser.where(locked_at: nil).first
        end

        def vsv
          @vsv ||= Muni::Login::Client::VendorSecretValidator.new
        end

      end
    end
  end
end
