module Muni
  module Login
    module Client
      class JsonProxy
        require 'net/http'

        def get_json(uri:, headers: {})
          result = { uri: uri }
          elapsed = Benchmark.measure do
            begin
              response = Net::HTTP.get_response(uri, { 'Accept' => 'text/json' }.merge(headers))
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

        def parse_json(json_string)
          Muni::Login::Client::ToolBox.reject_blanks(JSON.parse(json_string))
        end

      end
    end
  end
end
