require 'spec_helper'

RSpec.describe Muni::Login::Client::JwtDecoder do
  include_examples '~: sid_tokens'

  let(:subj) { described_class.new(expired_token) }

  describe "#jwt_decode" do
    it do
      expect(subj.jwt_decode)
        .to be_a(Hash)

      expect(subj.jwt_decode.keys.sort)
        .to eq(%w[aud exp iat iss sub])
    end
  end

end
