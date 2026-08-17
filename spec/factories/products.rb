FactoryBot.define do
  factory :product do
    name { Faker::Commerce.unique.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price { Faker::Commerce.price(range: 10..500) }
    stock { Faker::Number.between(from: 0, to: 200) }
    active { true }
    category

    trait :inactive do
      active { false }
    end

    trait :out_of_stock do
      stock { 0 }
    end

    trait :low_stock do
      stock { Faker::Number.between(from: 1, to: 5) }
    end
  end
end
