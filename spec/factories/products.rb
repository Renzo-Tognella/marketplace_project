FactoryBot.define do
  factory :product do
    name { FFaker::Product.product_name }
    price { FFaker::Number.decimal(whole_digits: 2, fractional_digits: 2) }
    description { FFaker::Lorem.sentence }
    stock_quantity { rand(1..100) }
    category { Product.categories.keys.sample }
    status { 'active' }
    
    trait :inactive do
      status { 'inactive' }
    end
    
    trait :out_of_stock do
      status { 'out_of_stock' }
      stock_quantity { 0 }
    end
  end
end