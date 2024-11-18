require 'spec_helper'

RSpec.describe Muni::Login::Client::IdpRequest do

  let(:controller_path) { random_hex_string }
  let(:action_name) { random_hex_string }
  let(:cookie_reader) { instance_double(Muni::Login::Client::CookieReader) }
  let(:http_headers) { Hash.new }
  let(:query_params) { Hash.new }
  let(:referrer) { random_hex_string }

  let(:subj) do
    described_class.new(
      controller_path: controller_path,
      action_name: action_name,
      cookie_reader: cookie_reader,
      http_headers: http_headers,
      referrer: referrer,
      query_params: query_params)
  end

  describe "referrer" do
    it do
      expect(subj.referrer).to eq(referrer)
    end
  end

  describe "api_token" do
    let(:http_headers) { { Muni::Login::Client::Base::API_TOKEN_HEADER => random_hex_string } }
    it do
      expect(subj.api_token).to eq(http_headers[Muni::Login::Client::Base::API_TOKEN_HEADER])
    end
  end

  describe "api_vector" do
    let(:http_headers) { { Muni::Login::Client::Base::API_VECTOR_HEADER => random_hex_string } }
    it do
      expect(subj.api_vector).to eq(http_headers[Muni::Login::Client::Base::API_VECTOR_HEADER])
    end
  end

  describe "action_signature" do
    it do
      expect(subj.action_signature).to eq("#{controller_path}|#{action_name}")
    end
  end

  describe "sid_token_from_query_params" do
    let(:sid_token) { SecureRandom.hex }
    let(:query_params) { { sid_token: sid_token } }

    context "enabled" do
      before do
        described_class.configure do |config|
          config.sid_token_from_query_params_allowed = true
        end
      end
      it do
        expect(subj.send(:sid_token_from_query_params)).to eq(sid_token)
      end
    end

    context "disabled" do
      before do
        described_class.configure do |config|
          config.sid_token_from_query_params_allowed = false
        end
      end
      it do
        expect(subj.send(:sid_token_from_query_params)).to be_nil
      end
    end
  end

end



