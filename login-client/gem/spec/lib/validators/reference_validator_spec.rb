require 'spec_helper'

RSpec.describe Muni::Login::Client::Validators::ReferenceValidator do

  let(:subj) do
    described_class.new(secure_identity: secure_identity)
  end

  before do
    Muni::Login::Client::IdpCache.new.clear
  end

  describe "#validate!" do
    context 'valid' do
      let(:user) { FactoryBot.create(:user) }
      let(:secure_identity) do
        FactoryBot.create(:secure_identity,
                          mod_name: user.class.name,
                          mod_id: user.id)
      end
      it do
        subj.send(:validate!)
      end
    end

    context 'locked identity' do
      let(:user) { FactoryBot.create(:user) }
      let(:secure_identity) do
        FactoryBot.create(:secure_identity,
                          mod_name: user.class.name,
                          mod_id: user.id,
                          locked_at: DateTime.current)
      end

      it do
        expect {
          subj.send(:validate!)
        }.to raise_error(Muni::Login::Client::Errors::Forbidden) { |error|
          expect(error.http_status).to eq(403)
          expect(error.error_code).to eq(1102)
          expect(error.title).to eq('Forbidden')
          expect(error.detail).to eq("The identity has been locked")
        }
      end
    end

    context 'locked reference' do
      let(:user) do
        FactoryBot.create(:user,
                          locked_at: DateTime.current)
      end
      let(:secure_identity) do
        FactoryBot.create(:secure_identity,
                          mod_name: user.class.name,
                          mod_id: user.id)
      end

      it do
        expect {
          subj.send(:validate!)
        }.to raise_error(Muni::Login::Client::Errors::Forbidden) { |error|
          expect(error.http_status).to eq(403)
          expect(error.error_code).to eq(1102)
          expect(error.title).to eq('Forbidden')
          expect(error.detail).to eq("The identity has been locked")
        }
      end
    end

  end

end



