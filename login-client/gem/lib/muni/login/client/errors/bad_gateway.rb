# 502 Bad Gateway
# This error is usually due to improperly configured proxy servers. However, the problem may
# also arise when there is poor IP communication between back—end computers, when the client's
# server is overloaded, or when a firewall is functioning improperly.
#
# The first step in resolving the issue is to clear the client's cache. This action should result
# in a different proxy being used to resolve the web server's content.
module Muni
  module Login
    module Client
      module Errors
        class BadGateway < Base
          def initialize(error_code: nil, detail: nil)
            super(
              http_status: 502,
              error_code: error_code || ERC_BAD_GATEWAY,
              detail: detail
            )
          end
        end
      end
    end
  end
end
