require 'spec_helper'

RSpec.describe Muni::Login::Client::Settings do

  let(:subj) { described_class.new }

  describe "#api_secrets" do

    before do
      allow(subj).to receive(:api_secrets_csv).and_return(api_secrets_csv)
    end

    context "nil" do
      let(:api_secrets_csv) { nil }
      it do
        expect {
          subj.api_secrets
        }.to raise_error(Muni::Login::Client::Errors::BadConfiguration) { |error|
          expect(error.http_status).to eq(500)
          expect(error.detail).to eq("Please set 'api_secrets_csv' to enable secure API tokens")
        }
      end
    end

    context "something" do
      let(:api_secrets_csv) { 'something' }
      it do
        expect(subj.api_secrets).to eq ['something']
      end
    end

    context "preserve case" do
      let(:api_secrets_csv) { 'FoX' }
      it do
        expect(subj.api_secrets).to eq ['FoX']
      end
    end

    context "no duplicates" do
      let(:api_secrets_csv) { 'something,something' }
      it do
        expect(subj.api_secrets).to eq ['something']
      end
    end

    context "strips whitespace" do
      let(:api_secrets_csv) { ' a  , b  ' }
      it do
        expect(subj.api_secrets).to eq ['a', 'b']
      end
    end

    context "rejects blanks" do
      let(:api_secrets_csv) { 'a,,,b' }
      it do
        expect(subj.api_secrets).to eq ['a', 'b']
      end
    end

    context "sorted" do
      let(:api_secrets_csv) { 'b,a' }
      it do
        expect(subj.api_secrets).to eq ['a', 'b']
      end
    end
  end
end

