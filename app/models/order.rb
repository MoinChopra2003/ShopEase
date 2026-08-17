class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address, optional: true
  has_many :order_items, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed shipped delivered cancelled] }
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, presence: true
  validates :delivery_address_snapshot, presence: true
end
