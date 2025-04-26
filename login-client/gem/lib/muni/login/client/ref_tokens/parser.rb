module Muni
  module Login
    module Client
      module RefTokens
        class Parser

          def initialize(encoded:, cipher: nil)
            @cipher = cipher || Cipher.new
            @encoded = encoded
          end

          # all legacy tokens are considered version 1
          def version
            @version ||= if decoded.dig(:envelope, :version).present?
                           # versioned envelopes should specify versions 2 or above
                           raise "invalid version" if decoded.dig(:envelope, :version).to_i < 2
                           decoded.dig(:envelope, :version).to_i
                         else
                           # 1 is reserved for legacy hashes, ones without an envelope
                           1
                         end
          end

          def body
            @body ||= if version < 2
                        decoded
                      else
                        cipher.decode_hash(decoded[:body])
                      end
          end

          # true if envelope contains a valid, authentic signature
          def authentic?
            included_signature.present? && (included_signature == actual_signature)
          end

          # the signature included with the token
          def included_signature
            @included_signature ||= if decoded.dig(:envelope, :signature).present?
                                      # decryption guarantees authenticity but not validity
                                      cipher.aes_decrypt(decoded.dig(:envelope, :signature))
                                    end
          end

          # actual signature, computed locally. This is the value we compare against when checking
          # for validity
          def actual_signature
            @actual_signature ||= if version < 2
                                    cipher.hex_digest(@encoded)
                                  else
                                    cipher.hex_digest(decoded[:body])
                                  end
          end

          private

          attr_reader :cipher

          def decoded
            @decoded ||= cipher.decode_hash(@encoded)
          end

        end
      end
    end
  end
end
