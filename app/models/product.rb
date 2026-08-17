class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :nullify
  has_one_attached :photo

  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }
  validates :category_id, presence: true
  validates :description, length: { maximum: 5000 }, allow_blank: true
end
