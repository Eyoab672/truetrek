class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  belongs_to :replied_to_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :replied_to_message_id, dependent: :nullify
  has_many_attached :photos
  has_many_attached :videos
  has_one_attached :voice_message

  validates :body, presence: true, unless: -> { photos.attached? || videos.attached? || voice_message.attached? }
  validate :acceptable_videos
  validate :acceptable_voice_message

  private

  def acceptable_videos
    return unless videos.attached?

    videos.each do |video|
      unless video.content_type.in?(%w[video/mp4 video/quicktime video/webm video/mpeg video/x-m4v])
        errors.add(:videos, "must be a video file (MP4, MOV, WebM)")
      end

      if video.byte_size > 100.megabytes
        errors.add(:videos, "must be less than 100MB")
      end
    end
  end

  def acceptable_voice_message
    return unless voice_message.attached?

    unless voice_message.content_type.in?(%w[audio/webm audio/mp4 audio/mpeg audio/ogg audio/wav audio/x-m4a])
      errors.add(:voice_message, "must be an audio file")
    end

    if voice_message.byte_size > 10.megabytes
      errors.add(:voice_message, "must be less than 10MB")
    end
  end

  public

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
