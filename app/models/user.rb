class User < ApplicationRecord
  has_secure_password

  attr_accessor :reset_token

  def create_reset_digest
    self.reset_token = SecureRandom.urlsafe_base64
    update!(
      password_reset_token_digest: BCrypt::Password.create(reset_token),
      password_reset_sent_at: Time.current
    )
  end

  def authenticated_reset_token?(token)
    return false if password_reset_token_digest.blank?

    BCrypt::Password.new(password_reset_token_digest).is_password?(token)
  end

  def reset_token_expired?
    password_reset_sent_at < 2.hours.ago
  end

  def clear_reset_digest
    update!(password_reset_token_digest: nil, password_reset_sent_at: nil)
  end

  has_one_attached :avatar

  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :support_requests, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true, inclusion: { in: %w[active inactive deleted] }
  validates :password, presence: true, length: { minimum: 8 }, if: -> { password_digest.blank? || password.present? }

  before_save { self.email = email.downcase }
end