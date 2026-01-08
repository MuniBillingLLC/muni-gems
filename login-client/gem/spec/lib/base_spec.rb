require 'spec_helper'

RSpec.describe Muni::Login::Client::Base do
  let(:subj) { described_class.new }

  describe "constants" do
    it "defines AUTHORIZATION_HEADER" do
      expect(described_class::AUTHORIZATION_HEADER).to eq("Authorization")
    end

    it "defines API_TOKEN_HEADER" do
      expect(described_class::API_TOKEN_HEADER).to eq("HTTP_X_API_TOKEN")
    end

    it "defines API_TOKEN_HEADER_RFC_7230" do
      expect(described_class::API_TOKEN_HEADER_RFC_7230).to eq("X-API-TOKEN")
    end

    it "defines API_VECTOR_HEADER" do
      expect(described_class::API_VECTOR_HEADER).to eq("HTTP_X_API_VECTOR")
    end

    it "defines API_VECTOR_HEADER_RFC_7230" do
      expect(described_class::API_VECTOR_HEADER_RFC_7230).to eq("X-API-VECTOR")
    end
  end

  describe "#dal" do
    it "returns a DataAccessLayer instance" do
      expect(subj.dal).to be_a(Muni::Login::Client::DataAccessLayer)
    end

    it "memoizes the instance" do
      expect(subj.dal).to be(subj.dal)
    end
  end

  describe "#gem_settings" do
    it "returns a Settings instance" do
      expect(subj.gem_settings).to be_a(Muni::Login::Client::Settings)
    end

    it "memoizes the instance" do
      expect(subj.gem_settings).to be(subj.gem_settings)
    end
  end
end
