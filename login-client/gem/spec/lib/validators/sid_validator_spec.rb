require 'spec_helper'

RSpec.describe Muni::Login::Client::Validators::SidValidator do

  let(:subj) do
    described_class.new(secure_identity: secure_identity)
  end

  describe "#ensure_unlocked_identity!" do
    context 'valid' do
      let(:secure_identity) { FactoryBot.create(:secure_identity) }
      it do
        subj.send(:ensure_unlocked_identity!)
      end
    end

    context 'invalid' do
      let(:secure_identity) { FactoryBot.create(:secure_identity, locked_at: DateTime.current) }
      it do
        expect {
          subj.send(:ensure_unlocked_identity!)
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



