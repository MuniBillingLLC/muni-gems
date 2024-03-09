require 'spec_helper'

RSpec.describe Muni::Login::Client::Wardens::SidWarden do

  include_examples '~: commons'
  include_examples '~: sid_tokens'
  include_examples '~: wardens'

  let(:idrequest) do
    instance_double(Muni::Login::Client::IdpRequest,
                    sid_token: known_token,
                    api_call_id: random_hex_string,
                    idlog: idlog)
  end

  describe "#authenticate_sid_token!" do
    it do
      expect_any_instance_of(Muni::Login::Client::ServiceProxy)
        .to receive(:authenticate_sid_token!)

      subj.send(:authenticate_sid_token!)
    end
  end

  describe "#decoded_token" do
    let(:mock_value) { random_hex_string }
    it 'delegates to JwtDecoder' do
      allow_any_instance_of(Muni::Login::Client::JwtDecoder)
        .to receive(:jwt_decode)
              .and_return(mock_value)
      expect(subj.send(:decoded_token))
        .to eq(mock_value)
    end

    it 'handles exceptionsa' do
      allow_any_instance_of(Muni::Login::Client::JwtDecoder)
        .to receive(:jwt_decode)
              .and_raise(RuntimeError.new(random_hex_string))

      expect {
        subj.send(:decoded_token)
      }.to raise_error(Muni::Login::Client::Errors::MalformedIdentity) { |error|
        expect(error.http_status).to eq(500)
        expect(error.detail).to eq('Invalid token')
      }
    end
  end

  describe "#sid_token" do
    it do
      expect(subj.send(:sid_token))
        .to eq(known_token)
    end
  end

  describe "#service_proxy" do
    it do
      expect(subj.send(:service_proxy))
        .to be_a(Muni::Login::Client::ServiceProxy)
    end
  end

end



