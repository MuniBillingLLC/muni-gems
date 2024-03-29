require 'spec_helper'

RSpec.describe Muni::Login::Client::VendorCreator do
  include_examples '~: commons'

  let(:subj) { described_class.new }

  describe "#provision" do
    let(:api_key) { random_hex_string }
    let(:name) { random_hex_string }
    let(:email) { random_hex_string }
    it do
      # creates new record
      expect {
        subj.provision(
          api_key: api_key,
          name: name,
          email: email)
      }.to change(ApiUser, :count).by(1)

      # ignores duplicates
      expect {
        subj.provision(
          api_key: api_key,
          name: name,
          email: email)
      }.to change(ApiUser, :count).by(0)
    end
  end

  describe "#provision_from_json" do
    let(:json_string) { '{ "name": "Muni Developer", "email": "engineer@munidev.local", "api_key": "API_TEST" }' }
    it do
      # creates new record
      expect {
        subj.provision_from_json(json_string)
      }.to change(ApiUser, :count).by(1)

      # ignores duplicates
      expect {
        subj.provision_from_json(json_string)
      }.to change(ApiUser, :count).by(0)
    end
  end

end
