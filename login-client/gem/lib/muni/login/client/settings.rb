module Muni
  module Login
    module Client
      class Settings
        include ::ActiveSupport::Configurable

        config_accessor :sid_cookie_name,
                        :sid_cookie_duration,
                        :sid_token_from_query_params_allowed,
                        :idpc_app_name,
                        :idpc_redis_bucket,
                        :idpc_retention,
                        :login_service_url_list,
                        :api_secrets_csv

        # Allow passing of SIDToken via query parameters. This is only
        # needed in specific cases, and is "false" by default
        def sid_token_from_query_params_allowed
          self.config.sid_token_from_query_params_allowed
        end

        # The name of the SID cookie
        def sid_cookie_name
          self.config.sid_cookie_name || ENV['MUNI_SID_COOKIE_NAME']
        end

        # Control the default policy of the sid cookie
        def sid_cookie_duration
          self.config.sid_cookie_duration || 7.days
        end

        # IDP cache policies
        def idpc_app_name
          self.config.idpc_app_name
        end

        # IDP cache policies
        def idpc_redis_bucket
          self.config.idpc_redis_bucket
        end

        # IDP cache policies
        def idpc_retention
          self.config.idpc_retention
        end

        # This is a CSV list (of strings), which is set during initialization
        # if the list is not set, the locator will always return the original URL
        def login_service_url_list
          self.config.login_service_url_list
        end

        # a special purpose API secret, for communicating between our own services
        def api_secret
          api_secrets.first
        end

        # the list of all available api secrets
        def api_secrets
          @api_secrets ||= if api_secrets_csv.present?
                             api_secrets_csv
                               .to_s
                               .split(',')
                               .map { |item| item.strip }
                               .reject { |item| item.blank? }
                               .uniq
                               .sort
                           else
                             # see https://jiramb.atlassian.net/browse/MBMAIN-8328
                             raise Muni::Login::Client::Errors::BadConfiguration.new(
                               detail: "Please set 'api_secrets_csv' to enable secure API tokens")
                           end
        end

        private

        # A CSV list of secrets fot this environment
        def api_secrets_csv
          self.config.api_secrets_csv || ENV['MUNI_API_SECRETS_CSV']
        end

      end
    end
  end
end
