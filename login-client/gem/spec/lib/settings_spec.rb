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

  describe "#parse_iso8601_duration" do
    let(:value) { 'P37D' }
    it do
      expect(subj.send(:parse_iso8601_duration,value))
        .to be_a(ActiveSupport::Duration)

      expect(subj.send(:parse_iso8601_duration,value))
        .to eq(37.days)
    end
  end

  describe "#sid_cookie_name (ENV fallback)" do
    around do |example|
      described_class.configure { |c| c.sid_cookie_name = nil }
      ClimateControl.modify(MUNI_SID_COOKIE_NAME: 'env-cookie-name') { example.run }
    end

    it "falls back to ENV when config not set" do
      expect(subj.sid_cookie_name).to eq('env-cookie-name')
    end
  end

  describe "#login_service_url_list (ENV fallback)" do
    around do |example|
      described_class.configure { |c| c.login_service_url_list = nil }
      ClimateControl.modify(LOGIN_SERVICE_URL_LIST: 'http://env.example.com') { example.run }
    end

    it "falls back to ENV when config not set" do
      expect(subj.login_service_url_list).to eq('http://env.example.com')
    end
  end

  describe "#idpc_redis_bucket" do
    # Reset the class variable before each test to ensure isolation
    before do
      if described_class.class_variable_defined?(:@@idpc_redis_bucket_deprecation_warned)
        described_class.remove_class_variable(:@@idpc_redis_bucket_deprecation_warned)
      end
    end

    it "returns nil" do
      expect(subj.idpc_redis_bucket).to be_nil
    end

    context "when explicitly configured (deprecated)" do
      before do
        described_class.configure { |c| c.idpc_redis_bucket = 'custom-bucket' }
      end

      after do
        described_class.configure { |c| c.idpc_redis_bucket = nil }
      end

      it "emits deprecation warning and still returns nil" do
        expect(ActiveSupport::Deprecation).to receive(:warn).with(/idpc_redis_bucket.*deprecated/)
        expect(subj.idpc_redis_bucket).to be_nil
      end

      it "emits deprecation warning only once across multiple instances" do
        expect(ActiveSupport::Deprecation).to receive(:warn).once

        # First call triggers warning
        described_class.new.idpc_redis_bucket
        # Second call on different instance should not warn
        described_class.new.idpc_redis_bucket
        # Third call should also not warn
        subj.idpc_redis_bucket
      end
    end
  end

  describe "#ignore_ssl_errors?" do
    context "when not configured" do
      before { described_class.configure { |c| c.ignore_ssl_errors = nil } }

      it { expect(subj.ignore_ssl_errors?).to be false }
    end

    context "when configured true" do
      before { described_class.configure { |c| c.ignore_ssl_errors = true } }

      it { expect(subj.ignore_ssl_errors?).to be true }
    end

    context "when configured false" do
      before { described_class.configure { |c| c.ignore_ssl_errors = false } }

      it { expect(subj.ignore_ssl_errors?).to be false }
    end
  end

end

