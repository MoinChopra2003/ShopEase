module Mutations
  class CreateProduct < BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false
    argument :price, Float, required: true
    argument :stock, Integer, required: true
    argument :category_id, ID, required: true
    argument :active, Boolean, required: false

    field :product, Types::ProductType, null: true
    field :errors, [String], null: false

    def resolve(name:, price:, stock:, category_id:, description: nil, active: true)
      user = context[:current_user]
      return { product: nil, errors: ["UNAUTHENTICATED"] } unless user

      category = Category.find_by(id: category_id)
      return { product: nil, errors: ["Category not found"] } unless category

      product = Product.new(
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        active: active
      )

      if product.save
        { product: product, errors: [] }
      else
        { product: nil, errors: product.errors.full_messages }
      end
    end
  end
end
