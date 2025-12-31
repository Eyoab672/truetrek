class ConversationMember < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  enum :role, { member: 0, admin: 1 }

  scope :active, -> { where(left_at: nil) }
  scope :admins, -> { where(role: :admin) }

  validates :user_id, uniqueness: { scope: :conversation_id, message: "is already a member" }

  def leave!
    update!(left_at: Time.current)
  end

  def active?
    left_at.nil?
  end
end
