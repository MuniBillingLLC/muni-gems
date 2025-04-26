module Muni
  module Login
    module Client
      module RefTokens
        class Cipher

          attr_reader :cipher_type

          def initialize(cipher_key: nil)
            @cipher_key = cipher_key
            @cipher_type = 'aes-256-cbc'
          end

          def aes_encrypt(value)
            cipher = OpenSSL::Cipher.new(cipher_type).encrypt
            cipher.key = valid_cipher_key!
            (cipher.update(value) + cipher.final).unpack('H*').first.upcase
          end

          def aes_decrypt(value)
            decipher = OpenSSL::Cipher.new(cipher_type).decrypt
            decipher.key = valid_cipher_key!
            begin
              decipher.update([value].pack('H*')) + decipher.final
            rescue StandardError => e
              nil
            end
          end

          def hex_digest(value)
            Digest::SHA256.hexdigest(value)
          end

          def encode_hash(hash)
            Base64.encode64(hash.to_json)
          end

          def decode_hash(encoded_string)
            encoded_string.present? ? JSON.parse(Base64.decode64(encoded_string)).with_indifferent_access : Hash.new
          end

          private

          # aes-256-cbc expects keys that are exactly 32 characters long
          def valid_cipher_key!
            return @valid_cipher_key if defined?(@valid_cipher_key)

            @valid_cipher_key = (@cipher_key || gem_settings.ref_token_secret).to_s[0, 32].squish
            raise "invalid cipher_key" unless @valid_cipher_key.size == 32
            @valid_cipher_key
          end

          def gem_settings
            @gem_settings ||= Muni::Login::Client::Settings.new
          end

        end
      end
    end
  end
end
