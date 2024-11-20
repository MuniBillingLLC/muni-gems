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
        allow_any_instance_of(Muni::Login::Client::Settings)
          .to receive(:sid_token_from_query_params_allowed?)
                .and_return(true)
      end
      it do
        expect(subj.send(:sid_token_from_query_params)).to eq(sid_token)
      end
    end

    context "disabled" do
      before do
        allow_any_instance_of(Muni::Login::Client::Settings)
          .to receive(:sid_token_from_query_params_allowed?)
                .and_return(false)
      end
      it do
        expect(subj.send(:sid_token_from_query_params)).to be_nil
      end
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

    context "from query params" do
      before do
        allow(subj).to receive(:sid_token_from_cookies).and_return(nil)
        allow(subj).to receive(:sid_token_from_headers).and_return(nil)
        allow(subj).to receive(:sid_token_from_query_params).and_return(sid_token)
      end

      it "returns the value" do
        expect(subj.sid_token).to eq(sid_token)
      end

      it "sets the origin" do
        expect {
          subj.sid_token
        }.to change {
          subj.sid_token_origin
        }.to('query_params')
      end

    end

  end

end



