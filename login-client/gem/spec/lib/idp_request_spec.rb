require 'spec_helper'

RSpec.describe Muni::Login::Client::IdpRequest do

  let(:controller_path) { random_hex_string }
  let(:action_name) { random_hex_string }
  let(:cookie_reader) { instance_double(Muni::Login::Client::CookieReader) }
  let(:http_headers) { Hash.new }
  let(:referer) { random_hex_string }

  let(:subj) do
    described_class.new(
      controller_path: controller_path,
      action_name: action_name,
      cookie_reader: cookie_reader,
      http_headers: http_headers,
      referer: referer)
  end

  describe "referer" do
    it do
      expect(subj.referer).to eq(referer)
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

end



