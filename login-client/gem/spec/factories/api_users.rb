FactoryBot.define do
  factory :api_user do
    name { SecureRandom.hex }
    email { SecureRandom.hex }
    api_key { SecureRandom.hex }
  end
end

