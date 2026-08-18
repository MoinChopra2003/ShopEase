module Types
  class OrderItemType < Types::BaseObject
    field :id, ID, null: false
    field :product, Types::ProductType, null: false
    field :quantity, Int, null: false
    field :price, Float, null: false

    def price
      object.price_at_purchase
    end
  end
end
