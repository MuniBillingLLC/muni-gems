# Having this class available to the client feels hacky. Ideally we want only the
# service (e.g. the IDP authority) to create SID's. And this is true for all realms
# except "ApiUser"
# For "ApiUser", we authorize "in place", with API key acting as a shared secret.
# E.g. no service call is ever made. Issuing an SID token for the (newly authorized)
# API user makes our code more uniform - we can pretend this is just another SID
# entity, store the SID into the keep and use the exact same implementation for figuring
# out what the "current identity" for all our principals
module Muni
  module Login
    module Client
      class SidCreator < Muni::Login::Client::Base

        def from_api_key(realm:, api_key:)
          unless [ApiUser.to_s].include?(realm)
            raise Muni::Login::Client::Errors::Unauthorized.new(detail: "Invalid realm")
          end

          api_user = dal.find_api_user_by_api_key(api_key)

          raise Muni::Login::Client::Errors::Unauthorized.new(detail: "Invalid api_key") if api_user.nil?

          find_or_create_secure_identity(mod_name: api_user.class.name, mod_id: api_user.id)
        end

        private

        def find_or_create_secure_identity(mod_name:, mod_id:)
          result = dal.find_secure_identity_by_mod(mod_name: mod_name, mod_id: mod_id)
          return result if result.present?

          # creating a new secure identity on the fly is a pretty invasive process. We blow up the
          # entire cache to make sure the newly created entity will be re-cached properly. Luckily,
          # this is a rare event.
          ::SecureIdentity.create!(
            sid: make_sid,
            mod_name: mod_name.to_s,
            mod_id: mod_id)
          dal.clear_cache
          dal.find_secure_identity_by_mod(mod_name: mod_name, mod_id: mod_id)
        end

        def make_sid
          "SID#{DateTime.now.utc.to_i}X#{SecureRandom.hex}".upcase
        end
      end
    end
  end
end
