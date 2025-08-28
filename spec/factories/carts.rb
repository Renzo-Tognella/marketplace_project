FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    abandoned { false }
    
    trait :abandoned do
      abandoned { true }
      updated_at { 3.hours.ago }
    end
    
    trait :old_abandoned do
      abandoned { true }
      updated_at { 7.days.ago }
    end
  end
end