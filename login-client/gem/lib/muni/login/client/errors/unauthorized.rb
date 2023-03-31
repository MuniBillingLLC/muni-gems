# frozen_string_literal: true
# Access to the requested resource is not authorized.
# The client request has not been completed because it lacks valid authentication
# credentials for the requested resource
module Muni
  module Login
    module Client
      module Errors
        class Unauthorized < Base
          def initialize(error_code: nil, detail: nil)
            super(
              http_status: 401,
              error_code: error_code || ERC_UNAUTHORIZED,
              detail: detail
            )
          end
        end
      end
    end
  end
end
