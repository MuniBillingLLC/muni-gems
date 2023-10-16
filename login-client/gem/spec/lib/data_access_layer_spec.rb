require 'spec_helper'

RSpec.describe Muni::Login::Client::DataAccessLayer do

  let(:subj) { described_class.new }

  before do
    Muni::Login::Client::IdpCache.new.clear
  end

  describe "#find_user_by_id" do
    let(:user) { FactoryBot.create(:user) }
    it do
      expect(subj.find_user_by_id(user.id))
        .to eq(user)
      expect(subj.find_user_by_id(user.id + 1))
        .to be_nil
    end
  end

  describe "#find_secure_identity_by_sid" do
    let(:secure_identity) { FactoryBot.create(:secure_identity) }
    it do
      expect(subj.find_secure_identity_by_sid(secure_identity.sid))
        .to eq(secure_identity)
      expect(subj.find_secure_identity_by_sid(random_hex_string))
        .to be_nil
    end
  end

  describe "#find_secure_identity_by_mod" do
    let(:user) { FactoryBot.create(:user) }
    let(:secure_identity) do
      FactoryBot.create(:secure_identity,
                        mod_name: user.class.name,
                        mod_id: user.id)
    end
    it do
      expect(subj.find_secure_identity_by_mod(
        mod_name: secure_identity.mod_name,
        mod_id: secure_identity.mod_id)
      ).to eq(secure_identity)

      expect(subj.find_secure_identity_by_mod(
        mod_name: random_hex_string,
        mod_id: secure_identity.mod_id)
      ).to be_nil

      expect(subj.find_secure_identity_by_mod(
        mod_name: secure_identity.mod_name,
        mod_id: secure_identity.mod_id + 1)
      ).to be_nil
    end
  end

  describe "#find_api_user_by_api_key" do
    let(:api_user) { FactoryBot.create(:api_user) }
    it do
      expect(subj.find_api_user_by_api_key(api_user.api_key))
        .to eq(api_user)
      expect(subj.find_api_user_by_api_key(random_hex_string))
        .to be_nil
    end
  end

  describe "#find_api_user_by_id" do
    let(:api_user) { FactoryBot.create(:api_user) }
    it do
      expect(subj.find_api_user_by_id(api_user.id))
        .to eq(api_user)
      expect(subj.find_api_user_by_id(api_user.id + 1))
        .to be_nil
    end
  end

  describe "#authenticate_sid_token!" do
    let(:loxy) { instance_double(Muni::Login::Client::ServiceProxy) }
    let(:sid_token) { random_hex_string }
    let(:decoded_token) do
      {
        sub: random_hex_string,
        iss: random_hex_string
      }
    end

    it do
      expect(loxy)
        .to receive(:authenticate_sid_token!)
              .with(sid_token: sid_token,
                    sid: decoded_token[:sub],
                    issuer_url: decoded_token[:iss])

      subj.authenticate_sid_token!(
        sid_token: sid_token,
        decoded_token: decoded_token,
        loxy: loxy)
    end

  end

  describe "#make_cache_key" do
    it do
      expect(subj.send(:make_cache_key, random_hash))
        .to include('"Muni::Login::Client::DataAccessLayer"')
    end
  end

end


