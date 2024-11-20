require 'spec_helper'

RSpec.describe Muni::Login::Client::CookieWriter do

  let(:cookie_jar) { instance_double(ActionDispatch::Cookies::CookieJar) }
  let(:plain_cookies) { Hash.new }
  let(:cookie_domain) { SecureRandom.hex }
  let(:sid_cookie_name) { random_hex_string }
  let(:sid_cookie_duration) { 3.days }

  let(:subj) do
    described_class.new(
      plain_cookies: plain_cookies,
      cookie_jar: cookie_jar,
      cookie_domain: cookie_domain)
  end

  before do
    allow(subj).to receive(:sid_cookie_name).and_return(sid_cookie_name)
    allow(subj).to receive(:sid_cookie_duration).and_return(sid_cookie_duration)
  end

  describe "#set_sid_token" do

    context 'blank value' do
      let(:value) { [nil, nil.to_s].sample }
      it do
        expect(cookie_jar)
          .to receive(:delete)
                .with(sid_cookie_name, domain: cookie_domain)

        subj.set_sid_token(value)
      end
    end

    context "non-blank value" do
      let(:value) { SecureRandom.hex }
      let(:expected) do
        {
          value: value,
          expires: sid_cookie_duration,
          domain: cookie_domain,
          path: "/",
          same_site: :strict
        }
      end
      it do
        expect {
          subj.set_sid_token(value)
        }.to change {
          subj.send(:sid_token)
        }.to(expected)
      end

    end

  end

end


