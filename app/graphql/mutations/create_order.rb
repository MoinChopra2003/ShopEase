module Mutations
  class CreateOrder < BaseMutation
    class OrderItemInput < GraphQL::Schema::InputObject
      argument :product_id, ID, required: true
      argument :quantity, Integer, required: true
    end

    argument :address_id, ID, required: false
    argument :items, [OrderItemInput], required: true

    field :order, Types::OrderType, null: true
    field :errors, [String], null: false

    def resolve(address_id: nil, items: [])
      user = context[:current_user]
      return { order: nil, errors: ["UNAUTHENTICATED"] } unless user

      if items.empty?
        return { order: nil, errors: ["Items cannot be empty"] }
      end

      ActiveRecord::Base.transaction do
        address = user.addresses.find_by(id: address_id) if address_id.present?

        order_number = "ORD#{Time.now.to_i}#{SecureRandom.hex(4)}"

        subtotal = 0.to_d
        address_snapshot = if address
                            address.attributes.except('created_at', 'updated_at', 'user_id')
                          else
                            { 'address_provided' => false }
                          end
        created_order = Order.create!(order_number: order_number, status: "pending", subtotal: 0, total_price: 0, user: user, address: address, delivery_address_snapshot: address_snapshot)

        items.each do |item|
          product = Product.find_by(id: item[:product_id])
          unless product
            raise ActiveRecord::RecordInvalid.new(created_order), "Product not found"
          end

          if product.stock && product.stock < item[:quantity]
            raise ActiveRecord::RecordInvalid.new(created_order), "Product #{product.id} does not have enough stock"
          end

          price = product.price
          line_total = price * item[:quantity]
          subtotal += line_total

          created_order.order_items.create!(quantity: item[:quantity], price_at_purchase: price, product_name_at_purchase: product.name, product: product)

          if product.stock
            product.decrement!(:stock, item[:quantity])
          end
        end

        total_price = subtotal
        created_order.update!(subtotal: subtotal, total_price: total_price)

        { order: created_order, errors: [] }
      end
    rescue ActiveRecord::RecordInvalid => e
      msg = e.message
      # If RecordInvalid from our manual raises, it may not have a record with errors; provide user-friendly message
      { order: nil, errors: [msg || "Failed to create order"] }
    rescue StandardError => e
      { order: nil, errors: ["Failed to create order"] }
    end
  end
end
