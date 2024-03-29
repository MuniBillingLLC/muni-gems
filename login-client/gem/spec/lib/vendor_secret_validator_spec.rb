require 'spec_helper'

RSpec.describe Muni::Login::Client::VendorSecretValidator do
  include_examples '~: commons'

  let(:subj) { described_class.new(idkeep: idkeep) }

  before do
    described_class.config_csv_secrets = csv_secrets
    allow(subj).to receive(:evar_csv_secrets).and_return(nil)
  end

  describe "#all_secrets" do

    context "nil" do
      let(:csv_secrets) { nil }
      it do
        expect {
          subj.send(:all_secrets)
        }.to raise_error(Muni::Login::Client::Errors::BadConfiguration) { |error|
          expect(error.http_status).to eq(500)
          expect(error.detail).to eq("Please set 'config_csv_secrets' to enable secure API tokens")
        }
      end
    end

    context "something" do
      let(:csv_secrets) { 'something' }
      it do
        expect(subj.send(:all_secrets)).to eq ['something']
      end
    end

    context "preserve case" do
      let(:csv_secrets) { 'FoX' }
      it do
        expect(subj.send(:all_secrets)).to eq ['FoX']
      end
    end

    context "no duplicates" do
      let(:csv_secrets) { 'something,something' }
      it do
        expect(subj.send(:all_secrets)).to eq ['something']
      end
    end

    context "strips whitespace" do
      let(:csv_secrets) { ' a  , b  ' }
      it do
        expect(subj.send(:all_secrets)).to eq ['a', 'b']
      end
    end

    context "rejects blanks" do
      let(:csv_secrets) { 'a,,,b' }
      it do
        expect(subj.send(:all_secrets)).to eq ['a', 'b']
      end
    end

    context "sorted" do
      let(:csv_secrets) { 'b,a' }
      it do
        expect(subj.send(:all_secrets)).to eq ['a', 'b']
      end
    end
  end

  describe "#is_valid?" do
    let(:secure_identity) { instance_double(SecureIdentity) }
    let(:csv_secrets) { 'dog,fox,donkey' }
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
