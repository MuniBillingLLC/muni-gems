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

  describe "#api_secret" do
    let(:value) { random_hex_string }
    it do
      allow(subj).to receive(:api_secrets).and_return([value, "garbage"])
      expect(subj.api_secret).to eq value
    end
  end

  describe "#log_trace_enabled?" do
    let(:value) { true }
    it do
      expect {
        described_class.configure do |config|
          config.log_trace_enabled = value
        end
      }.to change {
        described_class.new.log_trace_enabled?
      }.to(value)
    end
  end

  describe "#sid_token_from_query_params_allowed?" do
    let(:value) { true }
    it do
      expect {
        described_class.configure do |config|
          config.sid_token_from_query_params_allowed = value
        end
      }.to change {
        described_class.new.sid_token_from_query_params_allowed?
      }.to(value)
    end
  end

  describe "#sid_cookie_name" do
    let(:value) { random_hex_string }
    it do
      expect {
        described_class.configure do |config|
          config.sid_cookie_name = value
        end
      }.to change {
        described_class.new.sid_cookie_name
      }.to(value)
    end
  end

end

