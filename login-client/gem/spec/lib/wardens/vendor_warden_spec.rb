require 'spec_helper'

RSpec.describe Muni::Login::Client::Wardens::VendorWarden do

  include_examples '~: wardens'

  let(:api_user) { FactoryBot.create(:api_user) }
  let(:api_key) { api_user.api_key }

  let(:idrequest) do
    instance_double(Muni::Login::Client::IdpRequest, api_token: api_token)
  end

  describe "#validate_token!" do
    let(:api_secret) { random_hex_string }
    context 'configured' do
      before do
        described_class.config_api_secret = api_secret
      end
      context 'plain' do
        let(:api_token) { random_hex_string }
        it do
          subj.send(:validate_token!)
        end
      end
      context 'composite' do
        context 'valid' do
          let(:api_token) { [random_hex_string, api_secret].join(':') }
          it do
            subj.send(:validate_token!)
          end
        end
        context 'invalid' do
          let(:api_token) { [random_hex_string, random_hex_string].join(':') }
          it do
            expect {
              subj.send(:validate_token!)
            }.to raise_error(Muni::Login::Client::Errors::Unauthorized) { |error|
              expect(error.http_status).to eq(401)
              expect(error.title).to eq('Unauthorized')
              expect(error.detail).to eq("Invalid api_secret")
            }
          end
        end
      end
    end

    context 'unconfigured' do
      before do
        described_class.config_api_secret = nil
      end
      context 'plain' do
        let(:api_token) { random_hex_string }
        it do
          subj.send(:validate_token!)
        end
      end
      context 'composite' do
        let(:api_token) { [random_hex_string, random_hex_string].join(':') }
        it do
          subj.send(:validate_token!)
        end
      end
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



