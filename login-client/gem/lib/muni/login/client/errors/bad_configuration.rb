module Muni
  module Login
    module Client
      module Errors
        class BadConfiguration < Base
          def initialize(error_code: nil, detail: nil)
            super(error_code: error_code, detail: detail)
          end
        end
      end
    end
  end
end
