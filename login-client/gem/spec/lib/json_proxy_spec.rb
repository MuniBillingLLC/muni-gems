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

end



