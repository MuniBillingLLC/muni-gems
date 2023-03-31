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
