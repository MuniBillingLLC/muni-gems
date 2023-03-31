module Muni
  module Login
    module Client
      class ToolBox

        def self.reject_blanks(opts)
          if opts.is_a?(Hash)
            opts.reject { |k, v| v.blank? }
          elsif opts.is_a?(Array)
            opts.reject { |v| v.blank? }
          else
            opts
          end
        end

      end
    end
  end
end
