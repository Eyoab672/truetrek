require "open-uri"

class User < ApplicationRecord
  include PgSearch::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  pg_search_scope :search,
    against: [:username, :city],
    using: {
      tsearch: { prefix: true }
    }

  has_one :travel_book, dependent: :destroy
  accepts_nested_attributes_for :travel_book
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_one_attached :avatar

  # Follow relationships
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :followed
  has_many :reverse_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :reverse_follows, source: :follower

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

  # Follow helpers
  def following?(user)
    following.include?(user)
  end

  def follow(user)
    following << user unless self == user || following?(user)
  end

  def unfollow(user)
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

  # Check if user signed up via OAuth and hasn't set their city yet
  def needs_profile_completion?
    provider.present? && (city.blank? || city == "Not set")
  end

  # OmniAuth
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.username = generate_unique_username(auth.info.name || auth.info.email.split("@").first)
      user.city = "Not set"

      # Download and attach avatar from Google if available
      if auth.info.image.present?
        begin
          avatar_url = auth.info.image.gsub("=s96-c", "=s400-c") # Get larger image
          downloaded_image = URI.open(avatar_url)
          user.avatar.attach(io: downloaded_image, filename: "google_avatar.jpg", content_type: "image/jpeg")
        rescue StandardError => e
          Rails.logger.warn "Could not download Google avatar: #{e.message}"
        end
      end
    end
  end

  def self.generate_unique_username(base_name)
    username = base_name.parameterize(separator: "_")
    return username unless User.exists?(username: username)

    counter = 1
    loop do
      candidate = "#{username}_#{counter}"
      return candidate unless User.exists?(username: candidate)
      counter += 1
    end
  end
end
