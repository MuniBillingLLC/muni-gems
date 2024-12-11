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
                        :log_trace_enabled,
                        :api_secrets_csv

        # Allow passing of SIDToken via query parameters. This is only
        # needed in specific cases, and is "false" by default
        def sid_token_from_query_params_allowed?
          self.config.sid_token_from_query_params_allowed == true
        end

        # The name of the SID cookie
        def sid_cookie_name
          self.config.sid_cookie_name || ENV['MUNI_SID_COOKIE_NAME']
        end

        # Control the default policy of the sid cookie
        def sid_cookie_duration
          if self.config.sid_cookie_duration.present?
            self.config.sid_cookie_duration
          elsif ENV['MUNI_SID_COOKIE_DURATION'].present?
            # The format must mus follow the ISO 8601 duration format
            # Example: 'P7D', etc
            parse_iso8601_duration(ENV['MUNI_SID_COOKIE_DURATION'])
          else
            # The hardcoded default value
            7.days
          end
        end

        # The application name in the muni universe. You may see this in the logs
        # and some. It also impacts the redis storage location
        def idpc_app_name
          self.config.idpc_app_name
        end

        # Controls the location of the IDP cache storage in redis
        def idpc_redis_bucket
          self.config.idpc_redis_bucket || ENV['REDIS_NAMESPACE']
        end

        # Controls IDP cache duration
        def idpc_retention
          if self.config.idpc_retention.present?
            self.config.idpc_retention
          elsif ENV['MUNI_IDP_CACHE_DURATION'].present?
            # The format must mus follow the ISO 8601 duration format
            # Example: 'PT15M', 'PT1H', etc
            parse_iso8601_duration(ENV['MUNI_IDP_CACHE_DURATION'])
          else
            # The hardcoded default value
            15.minutes
          end
        end

        # This is a CSV list (of strings), which is set during initialization
        # if the list is not set, the locator will always return the original URL
        def login_service_url_list
          self.config.login_service_url_list || ENV['LOGIN_SERVICE_URL_LIST']
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

        # Controls IDP log levels. Never enable this in prod, since log traces
        # may contain privileged information. The setting is meant to facilitate development
        def log_trace_enabled?
          if self.config.log_trace_enabled.nil?
            ENV['MUNIDEV_IDPLOG_TRACE'].to_s.downcase == 'true'
          else
            self.config.log_trace_enabled == true
          end
        end

        private

        # A CSV list of secrets fot this environment
        def api_secrets_csv
          self.config.api_secrets_csv || ENV['MUNI_API_SECRETS_CSV']
        end

        def parse_iso8601_duration(value)
          ActiveSupport::Duration.parse(value)
        end

      end
    end
  end
end
