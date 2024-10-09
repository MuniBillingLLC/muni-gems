module Muni
  module Login
    module Client
      module Errors
        class Base < ::StandardError
          ERC_DEFAULT = 1001
          ERC_RECORD_NOT_FOUND = 1002
          ERC_FORBIDDEN = 1003
          ERC_BAD_GATEWAY = 1004

          ERC_UNAUTHORIZED = 1101
          ERC_FORBIDDEN_LOCKED = 1102
          ERC_IDP_NOT_REACHEABLE = 1103
          ERC_IDP_DECLINED = 1104

          attr_reader :http_status, :error_code

          def initialize(error_code: ERC_DEFAULT, http_status: nil, detail: nil)
            @error_code = error_code || ERC_DEFAULT
            @http_status = http_status || 500
            @detail = detail
          end

          def to_h
            Muni::Login::Client::ToolBox.reject_blanks(
              http_status: http_status,
              error_code: error_code,
              title: title,
              detail: detail
            )
          end

          def serializable_hash
            to_h.except(:http_status)
          end

          def to_s
            to_h.to_s
          end

          def title
            defaults.dig(:title)
          end

          def detail
            @detail || defaults.dig(:detail)
          end

          private

          def defaults
            case error_code
            when ERC_UNAUTHORIZED
              {
                title: "Unauthorized",
                detail: "You need to login to authorize this request."
              }
            when ERC_FORBIDDEN_LOCKED
              {
                title: "Forbidden",
                detail: "The identity has been locked"
              }
            when ERC_IDP_NOT_REACHEABLE
              {
                title: "Bad Gateway",
                detail: "IDP provider not reachable."
              }
            when ERC_IDP_DECLINED
              {
                title: "Unauthorized",
                detail: "Declined by IDP provider."
              }
            else
              {}
            end
          end

        end
      end
    end
  end
end
