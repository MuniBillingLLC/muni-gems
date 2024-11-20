module Muni
  module Login
    module Client
      class IdpCache

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
            app_name: gem_settings.idpc_app_name,
            redis_bucket: gem_settings.idpc_redis_bucket,
            retention: gem_settings.idpc_retention,
            adapter_name: "idp"
          )
        end

        def clear
          Rails.cache.clear
        end

        private


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

        def gem_settings
          @gem_settings ||= Muni::Login::Client::Settings.new
        end

      end
    end
  end
end
