module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :price, Float, null: false
    field :stock, Integer, null: false
    field :active, Boolean, null: false
    field :category, Types::CategoryType, null: false
  end
end
