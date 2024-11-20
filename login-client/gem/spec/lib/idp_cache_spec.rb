require 'spec_helper'

RSpec.describe Muni::Login::Client::IdpCache do
  let(:subj) { described_class.new }

  describe "#settings" do
    let(:idpc_retention) { 77.minutes }
    let(:idpc_app_name) { random_hex_string }
    let(:idpc_redis_bucket) { random_hex_string }
    let(:expected) do
      {
        :adapter_name => "idp",
        :app_name => idpc_app_name,
        :redis_bucket => idpc_redis_bucket,
        :retention => idpc_retention
      }
    end
    before do
      allow_any_instance_of(Muni::Login::Client::Settings)
        .to receive(:idpc_retention).and_return(idpc_retention)
      allow_any_instance_of(Muni::Login::Client::Settings)
        .to receive(:idpc_app_name).and_return(idpc_app_name)
      allow_any_instance_of(Muni::Login::Client::Settings)
        .to receive(:idpc_redis_bucket).and_return(idpc_redis_bucket)
    end
    it do
      expect(subj.settings).to eq(expected)
    end
  end

  describe "#fetch" do
    let(:expected) { random_hex_string }
    let(:cache_key) { random_hex_string }

    it do
      result = subj.fetch(cache_key: cache_key) do
        expected
      end
      expect(result).to eq(expected)
    end
  end

  describe "#delete" do
    let(:mock_store) { instance_double(ActiveSupport::Cache::FileStore) }
    let(:cache_key) { random_hex_string }

    it do
      allow(Rails).to receive(:cache).and_return(mock_store)
      expect(mock_store)
        .to receive(:delete)
      subj.delete(cache_key: cache_key)
    end
  end

  describe "#clear" do
    let(:mock_store) { instance_double(ActiveSupport::Cache::FileStore) }
    it do
      allow(Rails).to receive(:cache).and_return(mock_store)
      expect(mock_store)
        .to receive(:clear)
      subj.clear
    end
  end

  describe "#decorated" do
    let(:value) { { known_idp_key: "Known IDP value" } }
    it do
      expect(subj.send(:decorated, value))
        .to eq("spec_bucket.spec_app.idp.a36b83477223d2d5758cd5143459c256")
    end
  end

  describe "Rails.cache.fetch" do
    let(:expected) { random_hex_string }
    let(:cache_key) { random_hex_string }

    it do
      result = Rails.cache.fetch(cache_key) do
        expected
      end
      expect(result).to eq(expected)
    end
  end

end
