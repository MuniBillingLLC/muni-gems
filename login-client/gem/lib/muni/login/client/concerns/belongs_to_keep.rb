module Muni
  module Login
    module Client
      module Concerns
        module BelongsToKeep

          attr_reader :idkeep

          delegate :idlog, to: :idkeep



        end
      end
    end
  end
end
