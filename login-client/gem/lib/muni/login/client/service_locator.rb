# The service locator allows one service to have multiple aliases. For example
#   myservice.mydomain.com
# can also be available as
#   myothername.mydomain.com
# ... or even ...
#   myothername.myotherdomain.com
# This is particularly useful in development where services are on two different networks: the internal
# docker network and the external host network. Imagine service A depends on service B. Then A
# can be made aware of all possible addresses of B by setting the url_list config value. E.g. somewhere
# in A's initializers, you'll have:
#   config_url_list = "http//b1.somedomain, http//b2.anotherdomain"
# which will make it possible for A to find B inside on both host and docker networks and use the two
# interchangeably
module Muni
  module Login
    module Client
      class ServiceLocator
        include ActiveSupport::Configurable
        require "resolv"

        # This is a CSV list (of strings), which is set during initialization
        # if the list is not set, the locator will always return the original URL
        config_accessor :config_url_list

        def initialize(json_proxy:, idlog:)
          @idlog = idlog
          @json_proxy = json_proxy
        end

        def fetch_first_healthy(original_url)
          # original_url is considered healthy if there are no aliases
          return original_url if service_aliases.size < 2

          # when present, the alias list should always start with the original url
          # e.g if "b,c" are aliases of "a", then the list must be "a,b,c"
          return original_url unless service_aliases.starts_with?(original_url)

          # fine, the alias list is matches the original URL and it's not empty
          service_aliases.members.each do |uri|
            return uri if is_healthy?(uri: uri)
          end

          # if none is healthy - try again with "delete_cache: true". This helps auto-recover
          # from system-wide outages where the IDP was down for some time and we cached
          # that state
          idlog.info(
            location: "#{self.class.name}.#{__method__}",
            service_aliases: service_aliases.members,
            message: "No healthy endpoints found, attempting no_cache")
          service_aliases.members.each do |uri|
            return uri if is_healthy?(uri: uri, delete_cache: true)
          end

          # there's nothing else we can do
          idlog.info(
            location: "#{self.class.name}.#{__method__}",
            service_aliases: service_aliases.members,
            message: "The IDP provider is down")
          nil
        end

        # convert the CSV list to a proper array of URI objects
        def service_aliases
          @service_uris ||= Muni::Login::Client::UriGroup.parse_csv(self.config_url_list)
        end

        def checkpoint_uri(base_uri:, depth: 'small')
          URI.join(base_uri, 'api/checkpoints/', depth)
        end

        private

        attr_reader :json_proxy, :idlog

        delegate :get_json, to: :json_proxy

        def is_healthy?(uri:, delete_cache: false)
          fetch_health_response(uri: uri, delete_cache: delete_cache)&.dig(:code) == 200
        end

        def fetch_health_response(uri:, delete_cache:)
          healthcheck_uri = checkpoint_uri(base_uri: uri)

          cache_key = make_cache_key(
            method_name: __method__,
            healthcheck_url: healthcheck_uri.to_s)

          if delete_cache == true
            Muni::Login::Client::IdpCache.new.delete(cache_key: cache_key)
          end

          Muni::Login::Client::IdpCache.new.fetch(cache_key: cache_key, retention: 10.minutes) do
            begin
              response = get_json(uri: healthcheck_uri)

              if response[:code] != 200
                idlog.warn(
                  location: "#{self.class.name}.#{__method__}",
                  response: response)
              end
              response
            rescue StandardError => e
              idlog.warn(
                location: "#{self.class.name}.#{__method__}",
                healthcheck_uri: healthcheck_uri,
                exception: {
                  class: e.class.name,
                  message: e.message
                })

              # yield nil value so it can be cached and not attempted for a while
              nil
            end
          end
        end

        def make_cache_key(hash_signature)
          hash_signature.merge(class_name: self.class.name).to_s
        end

      end
    end
  end
end


