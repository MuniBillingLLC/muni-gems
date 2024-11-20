require 'spec_helper'

RSpec.describe Muni::Login::Client::VendorSecretValidator do
  include_examples '~: commons'

  let(:subj) { described_class.new(idkeep: idkeep) }

  before do
    allow_any_instance_of(Muni::Login::Client::Settings)
      .to receive(:api_secrets_csv)
            .and_return(api_secrets_csv)
  end


  describe "#is_valid?" do
    let(:secure_identity) { instance_double(SecureIdentity) }
    let(:api_secrets_csv) { 'dog,fox,donkey' }

    it 'true' do
      expect(subj.is_valid?(secure_identity: secure_identity, api_secret: nil))
        .to eq(false)
      expect(subj.is_valid?(secure_identity: secure_identity, api_secret: 'dog'))
        .to eq(true)
      expect(subj.is_valid?(secure_identity: secure_identity, api_secret: 'fox'))
        .to eq(true)
    end

    it 'false' do
      expect(subj.is_valid?(secure_identity: nil, api_secret: 'dog'))
        .to eq(false)
      expect(subj.is_valid?(secure_identity: secure_identity, api_secret: 'do'))
        .to eq(false)
      expect(subj.is_valid?(secure_identity: secure_identity, api_secret: 'Dog'))
        .to eq(false)
    end
  end

end
