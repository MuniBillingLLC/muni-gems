FactoryBot.define do
  factory :secure_identity do
    sid { SecureRandom.hex }
    mod_name { SecureRandom.hex }
    mod_id { rand(10000) }
  end
end
