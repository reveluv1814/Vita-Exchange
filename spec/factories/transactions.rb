FactoryBot.define do
  factory :transaction do
    user { nil }
    from_currency { "MyString" }
    to_currency { "MyString" }
    amount_from { "9.99" }
    amount_to { "9.99" }
    rate { "9.99" }
    status { "MyString" }
    error_message { "MyString" }
  end
end
