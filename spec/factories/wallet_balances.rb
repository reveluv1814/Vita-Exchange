FactoryBot.define do
  factory :wallet_balance do
    user { nil }
    currency { "MyString" }
    amount { "9.99" }
  end
end
