# Creating new vendors trough this interface is usually reserved for development environments
module Muni
  module Login
    module Client
      class VendorCreator < Muni::Login::Client::Base

        def provision_from_json(json_string)
          json = JSON.parse(json_string, symbolize_names: true)
          provision(api_key: json[:api_key],
                    name: json[:name],
                    email: json[:email])
        end

        def provision(api_key:, name:, email:)
          idlog.warn(
            location: "#{self.class.name}.#{__method__}",
            message: {
              api_key: "****",
              name: name,
              email: email
            })
          ::ApiUser.find_or_create_by(api_key: api_key) do |api_user|
            api_user.name = name
            api_user.email = email
          end
        end

        private

        def idlog
          @idlog ||= Muni::Login::Client::IdpLogger.new
        end

      end
    end
  end
end
