require 'spec_helper'

RSpec.describe Muni::Login::Client::RefTokens::Builder do
  let(:cipher) { Muni::Login::Client::RefTokens::Cipher.new(cipher_key: SecureRandom.hex(16)) }
  let(:body) do
    {
      "key1" => SecureRandom.hex,
      "key2" => SecureRandom.hex
    }
  end
  let(:encrypted_signature) { cipher.aes_encrypt(cipher.hex_digest(cipher.encode_hash(body))) }
  let(:encoded_body) { cipher.encode_hash(body) }

  let(:subj) { described_class.new(body: body, cipher: cipher) }

  describe "encoded_body" do
    let(:result) { subj.send(:encoded_body) }
    let(:expected) { encoded_body }
    it do
      expect(result).to eq(expected)
    end
  end

  describe "encrypted_signature" do
    let(:result) { subj.send(:encrypted_signature) }
    let(:expected) { encrypted_signature }
    it do
      expect(result).to eq(expected)
    end
  end

  describe "signed?" do
    it do
      expect(described_class.new(body: body).send(:signed?)).to eq(false)
      expect(described_class.new(body: body, signed: false).send(:signed?)).to eq(false)
      expect(described_class.new(body: body, signed: 'blah').send(:signed?)).to eq(false)
      expect(described_class.new(body: body, signed: 'true').send(:signed?)).to eq(false)
      expect(described_class.new(body: body, signed: true).send(:signed?)).to eq(true)
    end
  end

  describe "envelope" do
    let(:result) { subj.send(:envelope) }

    context "signed" do
      let(:subj) { described_class.new(body: body, signed: true, cipher: cipher) }
      let(:expected) { { version: 1, signature: encrypted_signature } }
      it do
        expect(result).to eq(expected)
      end
    end

    context "unsigned" do
      let(:expected) { { version: 1 } }
      it do
        expect(result).to eq(expected)
      end
    end

  end

  describe "call" do
    let(:result) { subj.call }

    context "legacy" do
      let(:expected) { encoded_body }
      it do
        expect(result).to eq(expected)
      end
    end

    context "v2" do
      let(:version) { 2 }
      let(:expected) { cipher.encode_hash(body: encoded_body, envelope: envelope) }
      context "signed" do
        let(:subj) { described_class.new(body: body, version: version, signed: true, cipher: cipher) }
        let(:envelope) { { version: version, signature: encrypted_signature } }
        it do
          expect(result).to eq(expected)
        end
      end

      context "unsigned" do
        let(:subj) { described_class.new(body: body, version: version, cipher: cipher) }
        let(:envelope) { { version: version } }
        it do
          expect(result).to eq(expected)
        end
      end
    end

  end

  describe "cipher" do
    let(:subj) { described_class.new(body: body) }
    let(:result) { subj.send(:cipher) }
    it do
      expect(result).to be_a(Muni::Login::Client::RefTokens::Cipher)
    end
  end

end


