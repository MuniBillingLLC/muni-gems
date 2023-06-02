require 'spec_helper'

RSpec.describe Muni::Login::Client::ServiceLocator do

  let(:primary_uri) { random_uri }
  let(:alternative_uri) { random_uri }

  let(:subj) do
    retval = described_class.new
    retval.config.config_url_list = [primary_uri.to_s, alternative_uri.to_s].join(',')
    retval
  end

  describe "#service_aliases" do
    context 'default' do
      let(:result) { described_class.new.service_aliases }
      it do
        expect(result.size)
          .to eq(2)
        expect(result.members).to_not include(primary_uri)
        expect(result.members).to_not include(alternative_uri)
      end
    end

    context 'custom' do
      let(:result) { subj.service_aliases }
      it do
        expect(result.size)
          .to eq(2)
        expect(result.members).to include(primary_uri)
        expect(result.members).to include(alternative_uri)
      end
    end
  end

  describe "#fetch_first_healthy" do

    it 'primary_uri' do
      allow(subj)
        .to receive(:is_healthy?)
              .and_return(true)

      expect(subj.fetch_first_healthy(primary_uri))
        .to eq(primary_uri)
    end

    it 'alternative_uri' do
      allow(subj)
        .to receive(:is_healthy?)
              .and_return(false, true)

      expect(subj.fetch_first_healthy(primary_uri))
        .to eq(alternative_uri)
    end
  end

end
