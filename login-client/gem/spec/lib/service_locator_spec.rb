require 'spec_helper'

RSpec.describe Muni::Login::Client::ServiceLocator do
  include_examples '~: commons'

  let(:primary_uri) { random_uri }
  let(:alternative_uri) { random_uri }
  let(:subj) { described_class.new(json_proxy: json_proxy, idlog: idlog) }
  let(:login_service_url_list) { [primary_uri.to_s, alternative_uri.to_s].join(',') }
  before do
    allow_any_instance_of(Muni::Login::Client::Settings)
      .to receive(:login_service_url_list)
            .and_return(login_service_url_list)
  end

  describe "#service_aliases" do
    let(:result) { subj.service_aliases }
    it do
      expect(result.size)
        .to eq(2)
      expect(result.members).to include(primary_uri)
      expect(result.members).to include(alternative_uri)
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
