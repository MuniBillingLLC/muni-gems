module Muni
  module Login
    module Client
      class SidCreator < Muni::Login::Client::Base

        def from_secret_token!(realm:, secret_token:)
          unless [ApiUser.to_s].include?(realm)
            raise Muni::Login::Client::Errors::Unauthorized.new(detail: "Invalid realm")
          end

          api_user = dal.find_api_user_by_secret_token(secret_token)

          raise Muni::Login::Client::Errors::Unauthorized.new(detail: "Invalid api key") if api_user.nil?

          find_or_create_secure_identity(mod_name: api_user.class.name, mod_id: api_user.id)
        end

        private

        def find_or_create_secure_identity(mod_name:, mod_id:)
          dal.find_secure_identity_by_mod(mod_name: mod_name, mod_id: mod_id) ||
            ::SecureIdentity.create!(
              sid: make_sid,
              mod_name: mod_name.to_s,
              mod_id: mod_id)
        end

        def make_sid
          "SID#{DateTime.now.utc.to_i}X#{SecureRandom.hex}".upcase
        end
      end
    end
  end
end
