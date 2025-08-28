FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { FFaker::Number.between(from: 1, to: 10) }
    
    trait :with_high_quantity do
      quantity { FFaker::Number.between(from: 10, to: 50) }
    end
  end
end