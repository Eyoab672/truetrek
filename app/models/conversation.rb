class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :messages, dependent: :destroy

  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }
  scope :for_user, ->(user) { where(sender: user).or(where(recipient: user)) }

  validates :sender_id, uniqueness: { scope: :recipient_id }
  validate :cannot_message_self

  def mutual_follow?
    sender.keeping_tabs_on?(recipient) && recipient.keeping_tabs_on?(sender)
  end

  def auto_accept_if_mutual!
    update!(accepted: true, accepted_at: Time.current) if mutual_follow? && !accepted?
  end

  def other_user(user)
    user == sender ? recipient : sender
  end

  def can_send_message?(user)
    return true if accepted? || mutual_follow?
    return true if user == sender && messages.count == 0
    false
  end

  def accept!
    update!(accepted: true, accepted_at: Time.current)
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def unread_count_for(user)
    messages.where.not(user: user).where(read_at: nil).count
  end

  private

  def cannot_message_self
    errors.add(:recipient, "can't message yourself") if sender_id == recipient_id
  end
end
