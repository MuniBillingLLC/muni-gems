require 'spec_helper'

RSpec.describe Muni::Login::Client::CookieReader do

  let(:subj) do
    described_class.new(plain_cookies: plain_cookies)
  end

  describe "#sid_token" do
    let(:value) { random_hex_string }
    let(:plain_cookies) do
      {
        described_class::SID_TOKEN => value
      }
    end
    it do
      expect(subj.sid_token).to eq(value)
    end
  end

end


