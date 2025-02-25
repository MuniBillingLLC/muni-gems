require 'spec_helper'

RSpec.describe Muni::Login::Client::CookieReader do
  let(:cookie_name) { random_hex_string }
  let(:cookie_value) { random_hex_string }
  let(:top_level_domain) { random_hex_string }

  let(:subj) do
    described_class.new(
      plain_cookies: plain_cookies,
      top_level_domain: top_level_domain)
  end

  before do
    allow(subj).to receive(:sid_cookie_name).and_return(cookie_name)
  end

  describe "#sid_token" do
    let(:plain_cookies) do
      {
        cookie_name => cookie_value
      }
    end
    it do
      expect(subj.sid_token).to eq(cookie_value)
    end
  end

  describe "#delete_sid_token" do
    let(:plain_cookies) { instance_double(ActionDispatch::Cookies::CookieJar, delete: nil) }
    it do
      expect(plain_cookies)
        .to receive(:delete)
              .with(cookie_name, domain: top_level_domain)

      subj.delete_sid_token
    end
  end

end


