require 'spec_helper'

RSpec.describe Muni::Login::Client::UriGroup do

  describe "#members" do
    let(:subj) { described_class.new }

    it do
      expect(subj.members).to be_empty
    end

  end

end
