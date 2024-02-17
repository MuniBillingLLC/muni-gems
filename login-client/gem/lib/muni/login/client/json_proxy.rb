# Example:
#   Muni::Login::Client::JsonProxy.new.get_json(uri: 'https://login.staging.munibilling.com/api/checkpoints/small')
module Muni
  module Login
    module Client
      class JsonProxy
        require 'net/http'

        def get_json(uri:, headers: {})
          result = { uri: to_uri(uri).to_s }
          elapsed = Benchmark.measure do
            begin
              response = get_response(to_uri(uri), { 'Accept' => 'text/json' }.merge(headers))
              result[:code] = response.code.to_i
              result[:size] = response.body.to_s.size
              result[:payload] = parse_json(response.body)
            rescue StandardError => e
              result[:code] = 0
              result[:error] = { class: e.class.name, message: e.message }
            end
          end
          result.merge(elapsed: elapsed.real.round(3)).with_indifferent_access
        end

        private

        def to_uri(value)
          if value.is_a?(String)
            URI.parse(value)
          else
            value
          end
        end

        def get_response(uri, headers)
          Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
            http.request(Net::HTTP::Get.new(uri.request_uri, headers))
          end
        end

        def parse_json(json_string)
          Muni::Login::Client::ToolBox.reject_blanks(JSON.parse(json_string))
        end

      end
    end
  end
end
