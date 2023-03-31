require 'spec_helper'

RSpec.describe Muni::Login::Client::SidCreator do

  let(:subj) { described_class.new }

  before do
    Muni::Login::Client::IdpCache.new.clear
  end

  describe "#from_secret_token!" do
    let(:api_user) { FactoryBot.create(:api_user) }

    context "authorized" do
      it do
        expect {
          subj.from_secret_token!(
            realm: api_user.class.name,
            secret_token: api_user.api_key)
        }.to change(SecureIdentity, :count).by(1)
      end
    end

    context "unauthorized" do
      it 'Invalid api key' do
        expect {
          subj.from_secret_token!(
            realm: api_user.class.name,
            secret_token: random_hex_string)
        }.to raise_error(Muni::Login::Client::Errors::Unauthorized) { |error|
          expect(error.http_status).to eq(401)
          expect(error.title).to eq('Unauthorized')
          expect(error.detail).to eq('Invalid api key')
        }
      end

      it 'Invalid realm' do
        expect {
          subj.from_secret_token!(
            realm: random_hex_string,
            secret_token: api_user.api_key)
        }.to raise_error(Muni::Login::Client::Errors::Unauthorized) { |error|
          expect(error.http_status).to eq(401)
          expect(error.title).to eq('Unauthorized')
          expect(error.detail).to eq('Invalid realm')
        }
      end
    end
  end

  describe "#find_or_create_secure_identity" do

    let(:mod_name) { User.to_s }
    let(:mod_id) { 1000 }

    context "create new" do
      it do
        expect {
          subj.send(:find_or_create_secure_identity,
                    mod_name: mod_name,
                    mod_id: mod_id)
        }.to change(SecureIdentity, :count).by(1)
      end
    end

    context "find existing" do
      let!(:sid) do
        FactoryBot.create(:secure_identity,
                          mod_name: mod_name,
                          mod_id: mod_id)
      end
      it do
        expect {
          subj.send(:find_or_create_secure_identity,
                    mod_name: sid.mod_name,
                    mod_id: sid.mod_id)
        }.to_not change(SecureIdentity, :count)
      end
    end

  end

end
