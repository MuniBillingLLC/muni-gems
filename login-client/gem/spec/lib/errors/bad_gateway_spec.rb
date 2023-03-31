require 'spec_helper'

RSpec.describe Muni::Login::Client::Errors::BadGateway do

  let(:subj) do
    described_class.new
  end

  it do
    expect(subj.http_status).to eq(502)
    expect(subj.error_code).to eq(1004)
  end

end



