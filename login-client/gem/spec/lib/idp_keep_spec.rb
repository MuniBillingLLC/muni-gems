require 'spec_helper'

RSpec.describe Muni::Login::Client::IdpKeep do

  let(:subj) do
    described_class.new
  end

  before do
    Muni::Login::Client::IdpCache.new.clear
  end

  describe "#customer" do
    let(:customer) { FactoryBot.create(:customer) }
    let(:secure_identity) do
      FactoryBot.create(:secure_identity,
                        mod_name: customer.class.name,
                        mod_id: customer.id)
    end
    let(:subj) do
      described_class.new(secure_identity: secure_identity)
    end
    it do
      expect(subj.customer).to eq(customer)
    end
  end

  describe "#user" do
    let(:user) { FactoryBot.create(:user) }
    let(:secure_identity) do
      FactoryBot.create(:secure_identity,
                        mod_name: user.class.name,
                        mod_id: user.id)
    end
    let(:subj) do
      described_class.new(secure_identity: secure_identity)
    end
    it do
      expect(subj.user).to eq(user)
    end
  end

  describe "#api_user" do
    let(:api_user) { FactoryBot.create(:api_user) }
    let(:secure_identity) do
      FactoryBot.create(:secure_identity,
                        mod_name: api_user.class.name,
                        mod_id: api_user.id)
    end
    let(:subj) do
      described_class.new(secure_identity: secure_identity)
    end
    it do
      expect(subj.api_user).to eq(api_user)
    end
  end

  describe "#sid" do
    let(:secure_identity) { FactoryBot.create(:secure_identity) }
    it do
      expect {
        subj.sid = secure_identity.sid
      }.to change {
        subj.sid
      }.to(secure_identity.sid).and change {
        subj.secure_identity
      }.to(secure_identity)
    end
  end

  describe "#sid_token" do
    let(:value) { random_hex_string }
    it do
      expect {
        subj.set_property(:sid_token, value)
      }.to change {
        subj.sid_token
      }.to(value)
    end
  end

  describe "#decoded_token" do
    let(:value) { random_hex_string }
    it do
      expect {
        subj.set_property(:decoded_token, value)
      }.to change {
        subj.decoded_token
      }.to(value)
    end
  end

  describe "#clear" do
    let(:subj) do
      described_class.new(secure_identity: FactoryBot.create(:secure_identity))
    end
    it do
      expect {
        subj.clear
      }.to change {
        subj.sid
      }.to(nil)
    end
  end

  describe "#system_api_user" do
    before do
      ApiUser.delete_all
    end

    context 'none' do
      it do
        expect(subj.send(:system_api_user))
          .to be_nil
      end
    end

    context 'first' do
      it do
        api_user = FactoryBot.create(:api_user)
        expect(subj.send(:system_api_user))
          .to eq(api_user)
      end
    end

    context 'by name' do
      it do
        FactoryBot.create(:api_user)
        api_user = FactoryBot.create(:api_user, api_key: 'SYSTEM_XXX')
        expect(subj.send(:system_api_user))
          .to eq(api_user)
      end
    end

    context 'by name not matching' do
      it do
        api_user = FactoryBot.create(:api_user)
        FactoryBot.create(:api_user, api_key: 'NOT_SYSTEM_XXX')
        expect(subj.send(:system_api_user))
          .to eq(api_user)
      end
    end
  end

  describe "#system_api_token" do
    let(:api_user) {  FactoryBot.create(:api_user, api_key: 'my_key') }
    it do
      allow_any_instance_of(Muni::Login::Client::VendorSecretValidator)
        .to receive(:system_api_secret)
              .and_return("my_secret")

      allow_any_instance_of(described_class)
        .to receive(:system_api_user)
              .and_return(api_user)

      expect(subj.system_api_token)
        .to eq("my_key:my_secret")
    end
  end


end



