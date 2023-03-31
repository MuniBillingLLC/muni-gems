require 'spec_helper'

RSpec.describe Muni::Login::Client::Errors::Forbidden do

  let(:subj) do
    described_class.new
  end

  it do
    expect(subj.http_status).to eq(403)
    expect(subj.error_code).to eq(1003)
  end

end



