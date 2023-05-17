FactoryBot.define do
  factory :customer do
    email { SecureRandom.hex }
  end

end
