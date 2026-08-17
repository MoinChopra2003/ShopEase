module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :order_number, String, null: false
    field :status, String, null: false
    field :subtotal, Float, null: false
    field :total_price, Float, null: false
    field :order_items, [Types::OrderItemType], null: false
    field :user, Types::UserType, null: false
    field :address, Types::AddressType, null: true
    field :delivery_address_snapshot, String, null: true
    field :created_at, String, null: false
    field :updated_at, String, null: false
  end
end