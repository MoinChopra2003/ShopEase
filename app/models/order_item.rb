class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_purchase, presence: true, numericality: { greater_than: 0 }
  validates :product_name_at_purchase, presence: true, length: { minimum: 2, maximum: 255 }
  validates :order_id, presence: true
  validates :product_id, presence: true
end
