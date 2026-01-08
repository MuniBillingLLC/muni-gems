require 'spec_helper'

RSpec.describe Muni::Login::Client::JsonProxy do

  let(:subj) do
    described_class.new
  end

  describe "#get_json" do
    let(:random_headers) { random_hash(symbolic_keys: false) }
    let(:uris) do
      [
        random_uri,
        URI.parse("http://fake.munidev.local:3000"),
        URI.parse("https://fake.munidev.local")
      ]
    end

    it 'random URI' do
      uris.each do |uri|
        result = subj.get_json(uri: uri, headers: random_headers)
        expect(result[:code]).to eq(0)
        expect(result.dig(:error, :message))
          .to include("Failed to open TCP connection to #{uri.host}:#{uri.port} (getaddrinfo")
      end
    end
  end

  describe "#get_response (SSL verification)" do
    let(:uri) { URI.parse("https://example.com/test") }
    let(:http_double) { instance_double(Net::HTTP) }
    let(:response_double) { instance_double(Net::HTTPResponse, code: "200", body: "{}") }
    let(:settings_double) { instance_double(Muni::Login::Client::Settings) }

    before do
      allow(http_double).to receive(:request).and_return(response_double)
      allow(subj).to receive(:gem_settings).and_return(settings_double)
    end

    context "when ignore_ssl_errors? is true" do
      before do
        allow(settings_double).to receive(:ignore_ssl_errors?).and_return(true)
      end

      it "passes verify_mode VERIFY_NONE to Net::HTTP.start" do
        expect(Net::HTTP).to receive(:start).with(
          "example.com", 443,
          hash_including(use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE)
        ).and_yield(http_double)
        subj.get_json(uri: uri)
      end
    end

    context "when ignore_ssl_errors? is false" do
      before do
        allow(settings_double).to receive(:ignore_ssl_errors?).and_return(false)
      end

      it "does not pass verify_mode to Net::HTTP.start" do
        expect(Net::HTTP).to receive(:start).with(
          "example.com", 443,
          hash_not_including(:verify_mode)
        ).and_yield(http_double)
        subj.get_json(uri: uri)
      end
    end
  end

end



