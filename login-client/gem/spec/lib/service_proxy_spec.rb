require 'spec_helper'

RSpec.describe Muni::Login::Client::ServiceProxy do
  include_examples '~: commons'

  let(:subj) { described_class.new(json_proxy: json_proxy, idlog: idlog) }

  let(:issuer_uri) { random_uri }
  let(:sid) { random_hex_string }

  describe "#check_status" do
    let(:depth) { ['small', 'medium'].sample }
    it do
      expect(subj.check_status(depth: depth))
        .to eq([{ 0 => json_proxy_response }, { 1 => json_proxy_response }])
    end
  end

  describe "#authenticate_sid_token!" do
    let(:sid_token) { random_hex_string }
    let(:issuer_url) { issuer_uri.to_s }
    let(:idp_response) { random_hash }

    it do
      expect(subj)
        .to receive(:fetch_first_healthy)
              .with(issuer_url: issuer_url)
              .and_return(issuer_uri)

      expect(subj)
        .to receive(:get_idp_response)
              .with(sid_token: sid_token, idp_uri: issuer_uri)
              .and_return(idp_response)

      expect(subj)
        .to receive(:validate_idp_response!)
              .with(sid: sid, idp_response: idp_response)

      subj.authenticate_sid_token!(
        sid_token: sid_token,
        sid: sid,
        issuer_url: issuer_url)
    end
  end

  describe "#validate_idp_response!" do
    let(:response_code) { 200 }
    let(:response_sid) { sid }
    let(:idp_response) do
      {
        :uri => issuer_uri,
        :code => response_code,
        :size => rand(100..500),
        :payload => {
          "sid" => response_sid,
          "meta" => { "response_version" => "1.0", "secure_identity_id" => 9, "created_at" => "2023-03-04T05:49:00.986Z" } },
        :elapsed => 5.151
      }.with_indifferent_access
    end

    context 'all good' do
      it do
        subj.send(:validate_idp_response!, sid: sid, idp_response: idp_response)
      end
    end

    context 'wrong response_code' do
      let(:response_code) { 201 }
      it do
        expect {
          subj.send(:validate_idp_response!, sid: sid, idp_response: idp_response)
        }.to raise_error(Muni::Login::Client::Errors::Unauthorized) { |error|
          expect(error.http_status).to eq(401)
          expect(error.title).to eq('Unauthorized')
          expect(error.detail).to eq("IDP responded with #{response_code}")
        }
      end
    end

    context 'wrong sid' do
      let(:response_sid) { random_hex_string }
      it do
        expect {
          subj.send(:validate_idp_response!, sid: sid, idp_response: idp_response)
        }.to raise_error(Muni::Login::Client::Errors::Unauthorized) { |error|
          expect(error.http_status).to eq(401)
          expect(error.title).to eq('Unauthorized')
          expect(error.detail).to eq("IDP SID mismatch")
        }
      end
    end

  end

  describe "#get_idp_response" do
    let(:idp_uri) { random_uri }
    let(:sid_token) { random_hex_string }

    it do
      subj.send(:get_idp_response, sid_token: sid_token, idp_uri: idp_uri)
    end

  end

  describe "#build_from_request" do
    let(:subj) { described_class.build_from_request(idrequest: idrequest) }

    it do
      expect(subj.send(:idp_locator))
        .to be_a(Muni::Login::Client::ServiceLocator)
    end
  end

end


