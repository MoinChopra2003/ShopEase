class Address < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :nullify

  validates :label, presence: true, length: { minimum: 2, maximum: 100 }
  validates :recipient_name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :address, presence: true, length: { minimum: 5, maximum: 255 }
  validates :city, presence: true, length: { minimum: 2, maximum: 100 }
  validates :country, presence: true, length: { minimum: 2, maximum: 100 }
  validates :postal_code, presence: true, format: { with: /\A[a-zA-Z0-9\s\-]{3,20}\z/, message: "must be a valid postal code" }
  validates :phone_number, presence: true, format: { with: /\A[+]?[0-9]{7,15}\z/, message: "must be a valid phone number" }
  validates :user_id, presence: true
  validates :default, inclusion: { in: [true, false] }
  validate :only_one_default_per_user

  private

  def only_one_default_per_user
    if default && user&.addresses&.where(default: true)&.where.not(id: id)&.exists?
      errors.add(:default, "can only have one default address per user")
    end
  end
end
