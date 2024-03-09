module Muni
  module Login
    module Client
      class DataAccessLayer

        def initialize
          @cache = Muni::Login::Client::IdpCache.new
        end

        def find_admin_by_id(admin_id)
          return nil if admin_id.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            admin_id: admin_id)

          @cache.fetch(cache_key: cache_key) do
            Admin.where(id: admin_id).first
          end
        end

        def find_user_by_id(user_id)
          return nil if user_id.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            user_id: user_id)

          @cache.fetch(cache_key: cache_key) do
            User.where(id: user_id).first
          end
        end

        def find_customer_by_id(customer_id)
          return nil if customer_id.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            customer_id: customer_id)

          @cache.fetch(cache_key: cache_key) do
            Customer.where(id: customer_id).first
          end
        end

        def find_secure_identity_by_sid(sid)
          return nil if sid.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            sid: sid)

          @cache.fetch(cache_key: cache_key) do
            SecureIdentity.where(sid: sid).first
          end
        end

        def find_secure_identity_by_mod(mod_name:, mod_id:)
          return nil if mod_id.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            mod_name: mod_name,
            mod_id: mod_id)

          @cache.fetch(cache_key: cache_key) do
            SecureIdentity.where(mod_name: mod_name.to_s, mod_id: mod_id).first
          end
        end

        def find_api_user_by_api_key(api_key)
          return nil if api_key.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            api_key_sha2: Digest::SHA2.hexdigest(api_key))

          @cache.fetch(cache_key: cache_key) do
            ApiUser.where(api_key: api_key).first
          end
        end

        def find_api_user_by_id(api_user_id)
          return nil if api_user_id.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            api_user_id: api_user_id)

          @cache.fetch(cache_key: cache_key) do
            ApiUser.where(id: api_user_id).first
          end
        end

        def authenticate_sid_token!(sid_token:, decoded_token:, service_proxy:)
          return nil if sid_token.nil?
          return nil if decoded_token.nil?
          return nil if service_proxy.nil?

          cache_key = make_cache_key(
            method_name: __method__,
            sid_token: sid_token)

          @cache.fetch(cache_key: cache_key) do
            service_proxy.authenticate_sid_token!(
              sid_token: sid_token,
              sid: decoded_token[:sub],
              issuer_url: decoded_token[:iss])
          end
        end

        def clear_cache
          @cache.clear
        end

        private

        def make_cache_key(hash_signature)
          hash_signature.merge(class_name: self.class.name).to_s
        end

      end
    end
  end
end
