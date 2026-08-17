# This file should ensure the existence of records required to run the application in every environment.
# The data can then be loaded with the bin/rails db:seed command.

# Clear existing data in the correct order (foreign key dependencies)
[Order, OrderItem, SupportRequest, Product, Address, User, Category, SupportArticle].each(&:delete_all)

puts "Creating categories..."
categories = [
  Category.create!(name: "Electronics", slug: "electronics"),
  Category.create!(name: "Clothing", slug: "clothing"),
  Category.create!(name: "Home & Garden", slug: "home-garden"),
  Category.create!(name: "Sports & Outdoors", slug: "sports-outdoors"),
  Category.create!(name: "Books & Media", slug: "books-media"),
  Category.create!(name: "Food & Beverages", slug: "food-beverages")
]

puts "Creating test user..."
test_user = User.create!(
  name: "Test User",
  email: "test@example.com",
  password: "TestPassword123!",
  password_confirmation: "TestPassword123!",
  status: "active"
)

puts "Creating addresses for test user..."
Address.create!(
  user: test_user,
  label: "Home",
  recipient_name: "Test User",
  phone_number: "+1234567890",
  address: "123 Main Street",
  city: "New York",
  country: "USA",
  postal_code: "10001",
  default: true
)

Address.create!(
  user: test_user,
  label: "Work",
  recipient_name: "Test User",
  phone_number: "+1234567891",
  address: "456 Work Avenue",
  city: "Los Angeles",
  country: "USA",
  postal_code: "90001",
  default: false
)

puts "Creating products..."
products_data = [
  # Electronics (10 products)
  { name: "Wireless Headphones", description: "High-quality noise-cancelling bluetooth headphones", price: 149.99, stock: 50, category: categories[0], active: true },
  { name: "USB-C Hub", description: "7-in-1 USB-C hub with HDMI and SD card reader", price: 49.99, stock: 100, category: categories[0], active: true },
  { name: "Portable Charger", description: "20000mAh power bank with dual charging ports", price: 29.99, stock: 75, category: categories[0], active: true },
  { name: "Smart Watch", description: "Fitness tracking smartwatch with heart rate monitor", price: 199.99, stock: 30, category: categories[0], active: true },
  { name: "Wireless Mouse", description: "Ergonomic wireless mouse with 2.4GHz connection", price: 25.99, stock: 120, category: categories[0], active: true },
  { name: "Mechanical Keyboard", description: "RGB mechanical keyboard with Cherry MX switches", price: 129.99, stock: 40, category: categories[0], active: true },
  { name: "4K Webcam", description: "Ultra HD webcam for streaming and video calls", price: 79.99, stock: 20, category: categories[0], active: true },
  { name: "LED Desk Lamp", description: "Adjustable LED lamp with USB charging port", price: 39.99, stock: 60, category: categories[0], active: true },
  { name: "Bluetooth Speaker", description: "Waterproof portable bluetooth speaker", price: 59.99, stock: 0, category: categories[0], active: true },
  { name: "HDMI Cable 2.1", description: "8K HDMI cable with ethernet support", price: 19.99, stock: 200, category: categories[0], active: true },

  # Clothing (5 products)
  { name: "Cotton T-Shirt", description: "100% cotton breathable t-shirt", price: 19.99, stock: 150, category: categories[1], active: true },
  { name: "Denim Jeans", description: "Classic blue denim jeans with stretch", price: 59.99, stock: 80, category: categories[1], active: true },
  { name: "Leather Jacket", description: "Premium leather jacket for all seasons", price: 199.99, stock: 25, category: categories[1], active: true },
  { name: "Running Shoes", description: "Professional running shoes with cushioning", price: 119.99, stock: 45, category: categories[1], active: true },
  { name: "Wool Beanie", description: "Warm wool beanie in multiple colors", price: 24.99, stock: 100, category: categories[1], active: true },

  # Home & Garden (5 products)
  { name: "Coffee Maker", description: "12-cup programmable coffee maker", price: 49.99, stock: 35, category: categories[2], active: true },
  { name: "Plant Pot Set", description: "Set of 3 ceramic plant pots with drainage", price: 34.99, stock: 55, category: categories[2], active: true },
  { name: "Bath Towel Set", description: "4-piece Egyptian cotton towel set", price: 44.99, stock: 70, category: categories[2], active: true },
  { name: "Bed Sheets", description: "Luxury 1000-thread-count bed sheets", price: 79.99, stock: 40, category: categories[2], active: true },
  { name: "Kitchen Knife Set", description: "8-piece stainless steel knife set", price: 89.99, stock: 30, category: categories[2], active: true },

  # Sports & Outdoors (5 products)
  { name: "Yoga Mat", description: "Non-slip 6mm yoga mat with carrying strap", price: 29.99, stock: 90, category: categories[3], active: true },
  { name: "Dumbbell Set", description: "Adjustable dumbbell set 5-50 lbs", price: 149.99, stock: 15, category: categories[3], active: true },
  { name: "Hiking Backpack", description: "50L waterproof hiking backpack", price: 129.99, stock: 25, category: categories[3], active: true },
  { name: "Tent 4-Person", description: "Lightweight 4-person camping tent", price: 179.99, stock: 20, category: categories[3], active: true },
  { name: "Bicycle Helmet", description: "Safety certified bicycle helmet", price: 69.99, stock: 50, category: categories[3], active: true },

  # Books & Media (5 products)
  { name: "The Great Gatsby", description: "Classic American novel by F. Scott Fitzgerald", price: 12.99, stock: 100, category: categories[4], active: true },
  { name: "Python Programming", description: "Complete guide to Python programming", price: 49.99, stock: 35, category: categories[4], active: true },
  { name: "Self-Help Bundle", description: "3-book self-help collection", price: 34.99, stock: 50, category: categories[4], active: true },
  { name: "Vinyl Record", description: "Retro vinyl record collection", price: 24.99, stock: 25, category: categories[4], active: true },
  { name: "audiobook Plus", description: "Annual audiobook subscription", price: 99.99, stock: 200, category: categories[4], active: true },

  # Food & Beverages (5 products)
  { name: "Organic Coffee Beans", description: "Premium organic arabica coffee beans (1kg)", price: 19.99, stock: 150, category: categories[5], active: true },
  { name: "Herbal Tea Set", description: "Assorted herbal tea collection", price: 29.99, stock: 80, category: categories[5], active: true },
  { name: "Dark Chocolate", description: "70% dark chocolate bar (100g)", price: 9.99, stock: 200, category: categories[5], active: true },
  { name: "Honey Jar", description: "Raw organic honey (500ml)", price: 14.99, stock: 60, category: categories[5], active: true },
  { name: "Protein Powder", description: "Whey protein powder vanilla flavor (2kg)", price: 59.99, stock: 40, category: categories[5], active: true }
]

products_data.each do |data|
  Product.create!(
    name: data[:name],
    description: data[:description],
    price: data[:price],
    stock: data[:stock],
    category: data[:category],
    active: data[:active]
  )
end

puts "Creating support articles..."
[
  { title: "Getting Started", content: "Welcome to our platform! This guide will help you get started with our services. Follow these steps to set up your account and start exploring our products and services.", position: 1, active: true },
  { title: "How to Place an Order", content: "Learn how to browse products, add items to your cart, and complete your purchase. Our checkout process is simple and secure. We accept all major payment methods.", position: 2, active: true },
  { title: "Shipping & Delivery", content: "Understand our shipping policies, delivery times, and tracking options. We ship worldwide with various delivery methods available.", position: 3, active: true },
  { title: "Returns & Refunds", content: "We offer a 30-day return policy on most items. Learn how to initiate a return and get your refund processed quickly.", position: 4, active: true },
  { title: "Account Security", content: "Tips for keeping your account secure including password management and two-factor authentication setup.", position: 5, active: true },
  { title: "Payment Methods", content: "We accept credit cards, debit cards, PayPal, Apple Pay, and Google Pay. All payments are encrypted and secure.", position: 6, active: true }
]
.each do |article|
  SupportArticle.create!(article)
end

puts "✅ Seed data created successfully!"
puts "  - Categories: #{Category.count}"
puts "  - Products: #{Product.count}"
puts "  - Users: #{User.count}"
puts "  - Addresses: #{Address.count}"
puts "  - Support Articles: #{SupportArticle.count}"
puts "\nTest user credentials:"
puts "  Email: test@example.com"
puts "  Password: TestPassword123!"
