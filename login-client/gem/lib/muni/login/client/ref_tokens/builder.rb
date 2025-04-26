module Muni
  module Login
    module Client
      module RefTokens
        class Builder

          def initialize(body:, version: 1, signed: false, cipher: nil)
            raise "invalid body" unless body.is_a? Hash
            @body = body
            @version = version
            @signed = signed
            @cipher = cipher || Cipher.new
          end

          def call
            if version < 2
              # legacy tokens have no envelopes
              encoded_body
            else
              cipher.encode_hash(body: encoded_body, envelope: envelope)
            end
          end

          private

          attr_reader :body, :version, :cipher

          # if true, we build a signed token
          def signed?
            @signed == true
          end

          def envelope
            if signed? == true
              { version: version, signature: encrypted_signature }
            else
              { version: version }
            end
          end

          def encoded_body
            @encoded_body ||= cipher.encode_hash(body)
          end

          #encrypting the signature guarantees its authenticity
          def encrypted_signature
            @signature ||= cipher.aes_encrypt(cipher.hex_digest(encoded_body))
          end

        end
      end
    end
  end
end
