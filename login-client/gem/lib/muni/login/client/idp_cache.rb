module Muni
  module Login
    module Client
      class IdpCache
        include ::ActiveSupport::Configurable

        config_accessor :config_app_name, :config_redis_bucket, :config_retention

        def delete(cache_key:)
          decorated_key = decorated(cache_key)
          message = {
            location: "#{self.class.name}.#{__method__}",
            cache_key: {
              original: cache_key,
              decorated: decorated_key
            }
          }
          Rails.logger.info message
          Rails.cache.delete(decorated_key)
        end

        def fetch(cache_key:, retention: settings[:retention])
          Rails.cache.fetch(decorated(cache_key), expires_in: retention) do
            yield
          end
        end

        def settings
          @settings ||= Muni::Login::Client::ToolBox.reject_blanks(
            app_name: self.config_app_name,
            redis_bucket: self.config_redis_bucket,
            retention: self.config_retention,
            adapter_name: adapter_name
          )
        end

        def clear
          Rails.cache.clear
        end

        private

        def adapter_name
          "idp"
        end

        def decorated(cache_key)
          result = []
          if norm(settings[:redis_bucket]).present?
            result << norm(settings[:redis_bucket])
          end
          if norm(settings[:app_name]).present?
            result << norm(settings[:app_name])
          end
          if norm(settings[:adapter_name]).present?
            result << norm(settings[:adapter_name])
          end
          if norm(cache_key).present?
            result << Digest::MD5.hexdigest(norm(cache_key))
          else
            raise "Invalid cache key"
          end
          result.join('.')
        end

        def norm(string)
          string.to_s.squish
        end

      end
    end
  end
end
