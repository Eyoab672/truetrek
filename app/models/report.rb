class Report < ApplicationRecord
  belongs_to :user
  belongs_to :place

  enum :status, { pending: 0, reviewed: 1, resolved: 2, dismissed: 3 }

  validates :reason, presence: true
  validates :user_id, uniqueness: { scope: :place_id, message: "has already reported this place" }

  REASONS = [
    "This place doesn't exist",
    "Incorrect information",
    "Duplicate place",
    "Inappropriate content",
    "Spam",
    "Other"
  ].freeze
end
