module Muni
  module Login
    module Client
      class UriGroup

        delegate :size, to: :members

        def initialize(members = [])
          @members = []
          members.each do |item|
            if item.is_a?(URI)
              @members << item
            else
              @members << URI.parse(item)
            end
          end
        end

        def members
          @members.clone
        end

        def starts_with?(uri)
          return false if members.empty?

          members[0] == uri
        end

        def self.parse_csv(value)
          self.new(value.to_s.split(','))
        end

      end
    end
  end
end
