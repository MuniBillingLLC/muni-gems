require 'spec_helper'

RSpec.describe Muni::Login::Client::IdpRequest do

  let(:controller_path) { random_hex_string }
  let(:action_name) { random_hex_string }
  let(:cookie_reader) { instance_double(Muni::Login::Client::CookieReader) }
  let(:http_headers) { Hash.new }
  let(:referrer) { random_hex_string }

  let(:subj) do
    described_class.new(
      controller_path: controller_path,
      action_name: action_name,
      cookie_reader: cookie_reader,
      http_headers: http_headers,
      referrer: referrer)
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

  describe "sid_token" do
    let(:sid_token) { random_hex_string }

    context "from cookies" do
      before do
        allow(subj).to receive(:sid_token_from_cookies).and_return(sid_token)
      end

      it "returns the value" do
        expect(subj.sid_token).to eq(sid_token)
      end

      it "sets the origin" do
        expect {
          subj.sid_token
        }.to change {
          subj.sid_token_origin
        }.to('cookies')
      end

    end

    context "from request header" do
      before do
        allow(subj).to receive(:sid_token_from_cookies).and_return(nil)
        allow(subj).to receive(:sid_token_from_headers).and_return(sid_token)
      end

      it "returns the value" do
        expect(subj.sid_token).to eq(sid_token)
      end

      it "sets the origin" do
        expect {
          subj.sid_token
        }.to change {
          subj.sid_token_origin
        }.to('request_header')
      end

    end

  end

end



