FactoryBot.define do
  factory :order_item do
    order
    product
    quantity { Faker::Number.between(from: 1, to: 5) }
    price_at_purchase { product.price }
    product_name_at_purchase { product.name }
  end
end
