module Muni
  module Login
    module Client
      module Concerns
        module BelongsToRequest

          attr_reader :idrequest

          delegate :idlog, to: :idrequest

        end
      end
    end
  end
end
