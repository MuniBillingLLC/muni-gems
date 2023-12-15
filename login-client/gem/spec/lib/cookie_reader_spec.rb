require 'spec_helper'

RSpec.describe Muni::Login::Client::CookieReader do

  let(:subj) do
    described_class.new(plain_cookies: plain_cookies)
  end

  describe "#sid_token" do
    let(:cookie_value) { random_hex_string }
    let(:cookie_name) { random_hex_string }
    let(:plain_cookies) do
      {
        cookie_name => cookie_value
      }
    end
    it do
      allow(subj).to receive(:sid_cookie_name).and_return(cookie_name)
      expect(subj.sid_token).to eq(cookie_value)
    end
  end

end


