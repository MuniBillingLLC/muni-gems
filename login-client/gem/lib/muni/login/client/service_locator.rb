module Muni
  module Login
    module Client
      class ServiceLocator
        include ActiveSupport::Configurable
        require "resolv"

        # This is a CSV list (of strings), which is set during initialization
        config_accessor :config_url_list

        def initialize(json_proxy: Muni::Login::Client::JsonProxy.new)
          @idlog = Muni::Login::Client::IdpLogger.new
          @joxy = json_proxy
        end

        def fetch_first_healthy(primary_uri)
          return primary_uri if redundancy_group.size < 2
          return primary_uri unless redundancy_group.starts_with?(primary_uri)
          redundancy_group.members.each do |uri|
            return uri if is_healthy?(uri: uri)
          end
          # if none is healthy - try again with "delete_cache: true". This helps auto-recover
          # from system-wide outages where the IDP was down for some time and we cached
          # that state
          idlog.info(
            class: self.class.name,
            method: __method__,
            redundancy_group: redundancy_group.members,
            message: "No healthy endpoints found, attempting no_cache")
          redundancy_group.members.each do |uri|
            return uri if is_healthy?(uri: uri, delete_cache: true)
          end
          # there's nothing else we can do
          idlog.info(
            class: self.class.name,
            method: __method__,
            redundancy_group: redundancy_group.members,
            message: "The IDP provider is down")
          nil
        end

        # convert the CSV list to a proper array of URI objects
        def redundancy_group
          @service_uris ||= Muni::Login::Client::UriGroup.parse_csv(self.config_url_list)
        end

        def checkpoint_uri(base_uri:, depth: 'small')
          URI.join(base_uri, 'api/checkpoints/', depth)
        end

        private

        attr_reader :joxy, :idlog

        delegate :get_json, to: :joxy

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
                  class: self.class.name,
                  method: __method__,
                  response: response)
              end
              response
            rescue StandardError => e
              idlog.warn(
                class: self.class.name,
                method: __method__,
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


