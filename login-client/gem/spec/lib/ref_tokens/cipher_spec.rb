require 'spec_helper'

RSpec.describe Muni::Login::Client::RefTokens::Cipher do
  let(:cipher_key) { "5a827cb0a8a3c8dab5ade705879beb61" }
  let(:known_hash) do
    {
      "key1" => "Be joyful in hope",
      "key2" => "And graceful in judgement"
    }
  end
  let(:known_encoding) { "eyJrZXkxIjoiQmUgam95ZnVsIGluIGhvcGUiLCJrZXkyIjoiQW5kIGdyYWNl\nZnVsIGluIGp1ZGdlbWVudCJ9\n" }
  let(:known_signature) { "2c219bafd2ac82b6b151441e10ff4a61495a0ff82160b2f6462f5a68f8f5aecf" }
  let(:known_encrypt) { "D32C5299CFA02053EF5CA2475ABB187EED4543BE95DEDBBE421A0E3D9C67B0CD7964E40BAFAA8F8A644C3FFEDF8D72A7F6DA1E2265F446EA900A2599857C5BE487786812314285292246080B8E2FA060" }

  let(:subj) { described_class.new(cipher_key: cipher_key) }

  describe 'cipher_type' do
    let(:result) { subj.cipher_type }
    it do
      expect(result).to eq('aes-256-cbc')
    end
  end

  describe 'aes_encrypt' do
    let(:result) { subj.aes_encrypt(known_signature) }
    it do
      expect(result).to_not eq(known_signature)
      expect(result).to eq(known_encrypt)
    end
  end

  describe 'aes_decrypt' do
    let(:result) { subj.aes_decrypt(known_encrypt) }
    it do
      expect(result).to_not eq(known_encrypt)
      expect(result).to eq(known_signature)
    end
  end

  describe 'hex_digest' do
    let(:result) { subj.hex_digest(known_encoding) }
    it do
      expect(result).to eq(known_signature)
    end
  end

  describe 'encode_hash' do
    let(:result) { subj.encode_hash(known_hash) }
    it do
      expect(result).to eq(known_encoding)
    end
  end

  describe 'decode_hash' do
    let(:result) { subj.decode_hash(known_encoding) }
    it do
      expect(result).to eq(known_hash)
    end
  end

  describe 'valid_cipher_key!' do
    let(:result) { subj.send(:valid_cipher_key!) }
    context 'exact length' do
      it do
        expect(result).to eq(cipher_key)
      end
    end

    context 'excess length' do
      let(:cipher_key) { SecureRandom.hex(17) }
      it do
        expect(result).to_not eq(cipher_key)
        expect(result).to eq(cipher_key[0, 32])
      end
    end

    context 'insufficient length' do
      let(:cipher_key) { SecureRandom.hex(15) }
      it do
        expect { result }.to raise_error(RuntimeError, "invalid cipher_key")
      end
    end
  end

end


