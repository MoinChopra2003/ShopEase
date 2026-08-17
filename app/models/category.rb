class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 255 }, uniqueness: true
  validates :slug, presence: true, length: { minimum: 2, maximum: 255 }, uniqueness: true
end
