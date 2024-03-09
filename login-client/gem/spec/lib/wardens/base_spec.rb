require 'spec_helper'

RSpec.describe Muni::Login::Client::Wardens::Base do

  include_examples '~: commons'
  include_examples '~: wardens'

  describe "#accept_identity" do
    let(:secure_identity) { FactoryBot.create(:secure_identity) }
    it do
      expect {
        subj.send(:accept_identity, secure_identity)
      }.to change {
        idkeep.secure_identity
      }.to(secure_identity)
    end
  end

  describe "#get_validator" do

    context "Missing identity" do
      it do
        expect {
          subj.send(:get_validator, nil)
        }.to raise_error(Muni::Login::Client::Errors::MalformedIdentity) { |error|
          expect(error.http_status).to eq(500)
          expect(error.detail).to eq("Missing identity")
        }
      end
    end

    context "Invalid model" do
      let(:secure_identity) { FactoryBot.create(:secure_identity) }
      it do
        expect(subj.send(:get_validator, secure_identity))
          .to be_a(Muni::Login::Client::SidValidator)
      end
    end

    context "User" do
      let(:secure_identity) { FactoryBot.create(:secure_identity, mod_name: User.to_s) }
      it do
        expect(subj.send(:get_validator, secure_identity))
          .to be_a(Muni::Login::Client::SidValidator)
      end
    end

    context "ApiUser" do
      let(:secure_identity) { FactoryBot.create(:secure_identity, mod_name: ApiUser.to_s) }
      it do
        expect(subj.send(:get_validator, secure_identity))
          .to be_a(Muni::Login::Client::SidValidator)
      end
    end
  end

end



