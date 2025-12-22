class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  enum :status, { pending: 0, reviewed: 1, resolved: 2, dismissed: 3 }

  validates :reason, presence: true
  validates :user_id, uniqueness: { scope: [:reportable_type, :reportable_id], message: "has already reported this" }

  PLACE_REASONS = [
    "This place doesn't exist",
    "Incorrect information",
    "Duplicate place",
    "Inappropriate content",
    "Spam",
    "Other"
  ].freeze

  COMMENT_REASONS = [
    "Inappropriate content",
    "Harassment or bullying",
    "Spam",
    "False information",
    "Hate speech",
    "Other"
  ].freeze

  # Legacy alias for compatibility
  REASONS = PLACE_REASONS

  def self.reasons_for(reportable_type)
    case reportable_type.to_s
    when "Comment"
      COMMENT_REASONS
    else
      PLACE_REASONS
    end
  end

  # Helper to check reportable type
  def place_report?
    reportable_type == "Place"
  end

  def comment_report?
    reportable_type == "Comment"
  end
end
