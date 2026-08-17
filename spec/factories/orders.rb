FactoryBot.define do
  factory :order do
    user
    address
    order_number { "ORD#{Time.now.to_i}#{SecureRandom.hex(4)}" }
    status { "pending" }
    subtotal { Faker::Commerce.price(range: 50..500) }
    total_price { subtotal }
    delivery_address_snapshot { address.attributes }

    trait :pending do
      status { "pending" }
    end

    trait :confirmed do
      status { "confirmed" }
    end

    trait :shipped do
      status { "shipped" }
    end

    trait :delivered do
      status { "delivered" }
    end

    trait :cancelled do
      status { "cancelled" }
    end
  end
end
