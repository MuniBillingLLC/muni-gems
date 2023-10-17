require 'spec_helper'

RSpec.describe Muni::Login::Client::Wardens::VendorWarden do

  include_examples '~: wardens'

  let(:api_user) { FactoryBot.create(:api_user) }
  let(:api_key) { api_user.api_key }

  let(:idrequest) do
    instance_double(Muni::Login::Client::IdpRequest, api_token: api_token)
  end

  describe "#validate_identity!" do
    let(:api_token) { "foo:bar" }
    let(:secure_identity) { FactoryBot.build(:secure_identity) }

    it 'pass' do
      expect_any_instance_of(Muni::Login::Client::VendorSecretValidator)
        .to receive(:is_valid?)
              .with(secure_identity: secure_identity,
                    api_secret: 'bar')
              .once
              .and_return(true)

      expect(subj.send(:validate_identity!, secure_identity))
        .to be_nil
    end

    it 'fail' do
      allow_any_instance_of(Muni::Login::Client::VendorSecretValidator)
        .to receive(:is_valid?)
              .with(secure_identity: secure_identity,
                    api_secret: 'bar')
              .and_return(false)

      expect {
        subj.send(:validate_identity!, secure_identity)
      }.to raise_error(Muni::Login::Client::Errors::Unauthorized) { |error|
        expect(error.http_status).to eq(401)
        expect(error.error_code).to eq(1101)
        expect(error.detail).to eq("invalid api_secret")
      }
    end

  end

  describe "#api_token" do
    let(:api_token) { random_hex_string }
    it do
      expect(subj.send(:api_token))
        .to eq(api_token)
    end
  end

  describe "#api_key" do
    context 'plain' do
      let(:api_token) { random_hex_string }
      it do
        expect(subj.send(:api_key))
          .to eq(api_token)
      end
    end
    context 'composite' do
      let(:api_token) { 'prefix:suffix' }
      it do
        expect(subj.send(:api_key))
          .to eq('prefix')
      end
    end
  end

  describe "#api_secret" do
    context 'plain' do
      let(:api_token) { random_hex_string }
      it do
        expect(subj.send(:api_secret))
          .to be_nil
      end
    end
    context 'composite' do
      let(:api_token) { 'prefix:suffix' }
      it do
        expect(subj.send(:api_secret))
          .to eq('suffix')
      end
    end
  end

end



