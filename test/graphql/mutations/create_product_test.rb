require "securerandom"
require "test_helper"

class CreateProductMutationTest < Minitest::Test
  def test_creates_a_product_with_valid_input
    user = User.create!(
      name: "Admin User",
      email: "admin-#{SecureRandom.uuid}@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      status: "active"
    )

    category = Category.create!(name: "Electronics", slug: "electronics")

    query = <<~GRAPHQL
      mutation CreateProduct($name: String!, $description: String, $price: Float!, $stock: Int!, $categoryId: ID!, $active: Boolean) {
        createProduct(name: $name, description: $description, price: $price, stock: $stock, categoryId: $categoryId, active: $active) {
          product {
            id
            name
            price
            stock
          }
          errors
        }
      }
    GRAPHQL

    result = FinalProjectSchema.execute(
      query,
      variables: {
        name: "Wireless Headphones",
        description: "Noise cancelling bluetooth headphones",
        price: 149.99,
        stock: 12,
        categoryId: category.id,
        active: true
      },
      context: { current_user: user }
    )

    assert_nil result["errors"], result.to_h.inspect
    assert result.dig("data", "createProduct", "product", "id").present?, result.to_h.inspect
    assert_equal "Wireless Headphones", result.dig("data", "createProduct", "product", "name")
    assert_equal [], result.dig("data", "createProduct", "errors")
    assert Product.find_by(name: "Wireless Headphones").present?
  end
end
