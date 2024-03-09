RSpec.shared_examples '~: sid_tokens' do

  let(:known_token) do
    [
      "eyJhbGciOiJIUzI1NiJ9.",
      "eyJpc3MiOiIzM2ZjMjI0MmY5ZTc2NzlkM2I5YmYwNDM3NjQwZTAyNyIsInN1YiI6ImNhZDM1ZDQ5",
      "ZjE3NDI3ODA2NDYyODI1ZWQyNjFjYzc2IiwiYXVkIjpbIjZlYmUxZDVmMmU4OWQyOGVkMGFlYWRk",
      "ZWM3YmU2YzEyIiwiOTEyNDMyYzcwZTcwM2ZiYzljMTI5OWM2YjZhOTEwN2MiXSwiZXhwIjoxNzEy",
      "NTA1MTUxLCJpYXQiOjE2Nzc1OTk1NTF9",
      ".BvUNU9etZhkFK6TSxOi2HXWkcQ37xfI2TFSVUJkc5uo"
    ].join(nil.to_s)
  end

end

RSpec.shared_examples '~: wardens' do
  let(:idkeep) { Muni::Login::Client::IdpKeep.new }

  let(:subj) do
    described_class.new(idrequest: idrequest, idkeep: idkeep)
  end

  before do
    Muni::Login::Client::IdpCache.new.clear
  end
end

RSpec.shared_examples '~: commons' do
  let(:idlog) do
    instance_double(Muni::Login::Client::IdpLogger,
                    bind: nil,
                    trace: nil,
                    info: nil,
                    warn: nil,
                    error: nil,
                    api_call_id: nil)
  end

  let(:json_proxy) do
    instance_double(Muni::Login::Client::JsonProxy, get_json: json_proxy_response)
  end

  let(:json_proxy_response) { random_hash }

  let(:idrequest) do
    instance_double(Muni::Login::Client::IdpRequest, idlog: idlog)
  end

  let(:idkeep) do
    instance_double(Muni::Login::Client::IdpKeep, idlog: idlog)
  end

end

