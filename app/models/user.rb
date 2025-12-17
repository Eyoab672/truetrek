class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :travel_book, dependent: :destroy
  accepts_nested_attributes_for :travel_book
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_one_attached :avatar

  # KeepTabs (follow) relationships
  has_many :keep_tabs, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :keep_tabs, source: :followed
  has_many :reverse_keep_tabs, class_name: "KeepTab", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :reverse_keep_tabs, source: :follower

  # Notifications
  has_many :notifications, dependent: :destroy

  # Conversations (DMs)
  has_many :sent_conversations, class_name: "Conversation", foreign_key: :sender_id, dependent: :destroy
  has_many :received_conversations, class_name: "Conversation", foreign_key: :recipient_id, dependent: :destroy

  validates :username, presence: true
  validates :city, presence: true

  def admin?
    admin
  end

  def banned?
    banned
  end

  # Devise override: prevent banned users from signing in
  def active_for_authentication?
    super && !banned?
  end

  # Custom message shown to banned users
  def inactive_message
    banned? ? :banned : super
  end

  # Convenience method for banning
  def ban!(reason: nil)
    update!(banned: true, banned_at: Time.current, banned_reason: reason)
  end

  # Convenience method for unbanning
  def unban!
    update!(banned: false, banned_at: nil, banned_reason: nil)
  end

  # KeepTabs helpers
  def keeping_tabs_on?(user)
    following.include?(user)
  end

  def keep_tabs_on(user)
    following << user unless self == user || keeping_tabs_on?(user)
  end

  def stop_keeping_tabs_on(user)
    following.delete(user)
  end

  def unread_notifications_count
    notifications.unread.count
  end

  # Conversation helpers
  def conversations
    Conversation.for_user(self)
  end

  def conversation_with(other_user)
    Conversation.find_by(sender: self, recipient: other_user) ||
      Conversation.find_by(sender: other_user, recipient: self)
  end

  def find_or_create_conversation_with(other_user)
    conversation_with(other_user) || sent_conversations.create!(recipient: other_user)
  end

  def unread_messages_count
    Message.joins(:conversation)
      .where("conversations.sender_id = ? OR conversations.recipient_id = ?", id, id)
      .where("conversations.accepted = ?", true)
      .where.not(user_id: id)
      .where(read_at: nil)
      .count
  end

  def pending_message_requests_count
    received_conversations.pending.count
  end
end
