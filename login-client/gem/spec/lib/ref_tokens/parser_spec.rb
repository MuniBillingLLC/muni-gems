require 'spec_helper'

RSpec.describe Muni::Login::Client::RefTokens::Parser do
  let(:cipher) { Muni::Login::Client::RefTokens::Cipher.new(cipher_key: SecureRandom.hex(16)) }
  let(:decoded) do
    {
      "key1" => SecureRandom.hex,
      "key2" => SecureRandom.hex
    }
  end
  let(:encoded) { cipher.encode_hash(decoded) }
  let(:subj) { described_class.new(encoded: encoded, cipher: cipher) }
  let(:unsigned_envelope) { { version: rand(10..100) } }

  describe "version" do
    let(:result) { subj.version }
    context "legacy" do
      it do
        expect(result).to eq(1)
      end
    end

    context "versioned" do
      let(:decoded) { { envelope: unsigned_envelope } }
      it do
        expect(result).to eq(unsigned_envelope.dig(:version))
      end
    end

    context "mis-versioned" do
      let(:unsigned_envelope) { { version: 1 } }
      let(:decoded) { { envelope: unsigned_envelope } }
      it do
        expect { result }.to raise_error(RuntimeError, "invalid version")
      end
    end
  end

  describe "body" do
    let(:result) { subj.body }
    context "legacy" do
      it do
        expect(result).to eq(decoded)
      end
    end

    context "versioned" do
      let(:body_hash) do
        {
          "key1" => SecureRandom.hex,
          "key2" => SecureRandom.hex
        }
      end
      let(:encoded_body) { cipher.encode_hash(body_hash) }
      let(:decoded) { { body: encoded_body, envelope: unsigned_envelope } }
      it do
        expect(result).to eq(body_hash)
      end
    end
  end

  describe "actual_signature" do
    let(:result) { subj.actual_signature }

    context "legacy" do
      let(:expected) { cipher.hex_digest(encoded) }
      it do
        expect(result).to eq(expected)
      end
    end

    context "versioned" do
      let(:body_hash) do
        {
          "key1" => SecureRandom.hex,
          "key2" => SecureRandom.hex
        }
      end
      let(:encoded_body) { cipher.encode_hash(body_hash) }
      let(:decoded) { { body: encoded_body, envelope: unsigned_envelope } }
      let(:expected) { cipher.hex_digest(encoded_body) }
      it do
        expect(result).to eq(expected)
      end
    end
  end

  describe "included_signature" do
    let(:result) { subj.included_signature }

    let(:body_hash) do
      {
        "key1" => SecureRandom.hex,
        "key2" => SecureRandom.hex
      }
    end
    let(:encoded_body) { cipher.encode_hash(body_hash) }
    let(:signed_envelope) { { version: rand(10..100), signature: encrypted_signature } }
    let(:decoded) { { body: encoded_body, envelope: signed_envelope } }
    let(:plain_signature) { cipher.hex_digest(encoded_body) }
    let(:encrypted_signature) { cipher.aes_encrypt(plain_signature) }

    context "authentic" do
      context "real" do
        it do
          expect(result).to eq(plain_signature)
          expect(subj.authentic?).to eq(true)
        end
      end

      context "fake" do
        let(:plain_signature) { SecureRandom.hex }
        it do
          expect(result).to eq(plain_signature)
          expect(subj.authentic?).to eq(false)
        end
      end
    end

    context "tampered" do
      let(:encrypted_signature) { SecureRandom.hex }

      context "real" do
        it do
          expect(result).to be_nil
          expect(subj.authentic?).to eq(false)
        end
      end

      context "fake" do
        let(:plain_signature) { SecureRandom.hex }
        it do
          expect(result).to be_nil
          expect(subj.authentic?).to eq(false)
        end
      end
    end

  end

end


