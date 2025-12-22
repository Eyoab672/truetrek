class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, uniqueness: { scope: :followed_id, message: "already following this user" }
  validate :cannot_follow_self

  after_create :notify_followed_user
  before_destroy :cleanup_old_notifications

  private

  def cannot_follow_self
    errors.add(:follower_id, "can't follow yourself") if follower_id == followed_id
  end

  def notify_followed_user
    # Remove any existing follow notification from this user first
    Notification.where(
      user: followed,
      actor: follower,
      action: "new_follow"
    ).destroy_all

    Notification.create!(
      user: followed,
      actor: follower,
      notifiable: self,
      action: "new_follow"
    )
  end

  def cleanup_old_notifications
    Notification.where(notifiable: self).destroy_all
  end
end
