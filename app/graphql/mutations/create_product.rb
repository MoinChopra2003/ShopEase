module Mutations
  class CreateProduct < BaseMutation
    argument :name, String, required: true
    argument :description, String, required: false
    argument :price, Float, required: true
    argument :stock, Integer, required: true
    argument :category_id, ID, required: true
    argument :active, Boolean, required: false
    argument :photo_base64, String, required: false

    field :product, Types::ProductType, null: true
    field :errors, [ String ], null: false

    def resolve(
      name:,
      price:,
      stock:,
      category_id:,
      description: nil,
      active: true,
      photo_base64: nil
    )
      user = context[:current_user]
      return { product: nil, errors: [ "UNAUTHENTICATED" ] } unless user

      category = Category.find_by(id: category_id)
      return { product: nil, errors: [ "Category not found" ] } unless category

      product = Product.new(
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        active: active
      )

      if photo_base64.present?
        data = photo_base64
        mime = nil

        if data.start_with?("data:")
          parts = data.split(",", 2)
          data = parts.last
          mime = parts.first.match(/data:(.*);base64/)&.captures&.first
        end

        decoded = Base64.decode64(data)

        product.photo.attach(
          io: StringIO.new(decoded),
          filename: "product_#{Time.now.to_i}.jpg",
          content_type: mime || "image/jpeg"
        )
      end

      if product.save
        { product: product, errors: [] }
      else
        { product: nil, errors: product.errors.full_messages }
      end
    rescue StandardError
      { product: nil, errors: [ "Failed to create product" ] }
    end
  end
end
