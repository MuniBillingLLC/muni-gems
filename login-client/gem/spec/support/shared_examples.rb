RSpec.shared_examples '~: sid_tokens' do

  let(:expired_token) do
    [
      "eyJhbGciOiJIUzI1NiJ9.",
      "eyJpc3MiOiIzM2ZjMjI0MmY5ZTc2NzlkM2I5YmYwNDM3NjQwZTAyNyIsInN1YiI6ImNhZDM1ZDQ5",
      "ZjE3NDI3ODA2NDYyODI1ZWQyNjFjYzc2IiwiYXVkIjpbIjZlYmUxZDVmMmU4OWQyOGVkMGFlYWRk",
      "ZWM3YmU2YzEyIiwiOTEyNDMyYzcwZTcwM2ZiYzljMTI5OWM2YjZhOTEwN2MiXSwiZXhwIjoxNzEy",
      "NTA1MTUxLCJpYXQiOjE2Nzc1OTk1NTF9",
      ".BvUNU9etZhkFK6TSxOi2HXWkcQ37xfI2TFSVUJkc5uo"
    ].join(nil.to_s)
  end

  let(:jwt_key) do
    SecureRandom.hex
  end

  # this is arguably the most important part of the token, it contains the SID value
  let(:jwt_subject) do
    SecureRandom.hex
  end

  let(:valid_token) do
    JWT.encode(jwt_claims, jwt_key)
  end

  let(:jwt_claims) do
    {
      iss: "http://#{SecureRandom.hex(3)}.#{SecureRandom.hex(3)}.local",
      sub: jwt_subject,
      exp: (DateTime.current + 3.days).utc.to_i,
      iat: DateTime.current.utc.to_i
    }
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
                    api_vector: nil)
  end

  let(:json_proxy) do
    instance_double(Muni::Login::Client::JsonProxy, get_json: json_proxy_response)
  end

  let(:json_proxy_response) { random_hash }

  let(:idrequest) do
    instance_double(Muni::Login::Client::IdpRequest,
                    idlog: idlog,
                    api_vector: api_vector,
                    sid_token_origin: random_hex_string)
  end

  let(:idkeep) do
    instance_double(Muni::Login::Client::IdpKeep, idlog: idlog)
  end

  let(:api_vector) { random_hex_string }

end

