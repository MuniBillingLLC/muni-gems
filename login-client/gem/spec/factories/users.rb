FactoryBot.define do
  factory :user do
    email { SecureRandom.hex }
  end

end
