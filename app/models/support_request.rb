class SupportRequest < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true, length: { minimum: 3, maximum: 255 }
  validates :message, presence: true, length: { minimum: 10, maximum: 5000 }
  validates :status, presence: true, inclusion: { in: %w[open in_progress resolved closed] }
  validates :user_id, presence: true
end
