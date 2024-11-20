module Muni
  module Login
    module Client
      class IdpKeep < Muni::Login::Client::Base

        # sometimes it is necessary for upstream to clear the idkeep
        # cache. This is rare and usually happens when the stored identity
        # (user,admin,customer) has been modified in the database and we
        # need to fetch a fresh copy. Clearing the cache is a benign operation
        # and does not affect the stored identities.
        delegate :clear_cache, to: :dal

        def initialize(secure_identity: nil)
          @properties = {}
          self.sid = secure_identity&.sid
        end

        # Clear the keep, expel all stored identities and metadata. This operation
        # is highly intrusive, it flushes the keep and is usually performed at sing-out
        def clear
          idlog.trace(
            location: "#{self.class.name}.#{__method__}",
            sid: sid)

          @properties.clear
          clear_cache
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
            gem_settings.api_secret
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

        def idlog
          @idlog ||= Muni::Login::Client::IdpLogger.new
        end

        private

        # a special purpose API user, for communicating between our own services
        def system_api_user
          @system_api_user ||= ApiUser.where("api_key like 'SYSTEM_%'").first || ApiUser.where(locked_at: nil).first
        end


        def gem_settings
          @gem_settings ||= Muni::Login::Client::Settings.new
        end

      end
    end
  end
end
