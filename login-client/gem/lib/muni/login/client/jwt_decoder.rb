module Muni
  module Login
    module Client
      class JwtDecoder
        require 'jwt'

        def initialize(encoded)
          @encoded = encoded
        end

        def jwt_decode
          JWT.decode(@encoded, nil, false).first.with_indifferent_access
        end

      end
    end
  end
end

