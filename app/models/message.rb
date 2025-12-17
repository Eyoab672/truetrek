class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  belongs_to :replied_to_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :replied_to_message_id, dependent: :nullify
  has_many_attached :photos

  validates :body, presence: true, unless: -> { photos.attached? }

  scope :chronological, -> { order(created_at: :asc) }
  scope :recent_first, -> { order(created_at: :desc) }

  def can_unsend?
    created_at > 48.hours.ago
  end

  def owned_by?(u)
    user_id == u.id
  end

  def mark_as_read!
    update!(read_at: Time.current) if read_at.nil?
  end
end
