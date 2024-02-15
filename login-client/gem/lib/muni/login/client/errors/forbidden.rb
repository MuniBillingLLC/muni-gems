# 403 Forbidden
module Muni
  module Login
    module Client
      module Errors
        class Forbidden < Base
          def initialize(error_code: nil, detail: nil)
            super(
              http_status: 403,
              error_code: error_code || ERC_FORBIDDEN,
              detail: detail
            )
          end
        end
      end
    end
  end
end
