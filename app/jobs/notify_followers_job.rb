class NotifyFollowersJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find_by(id: comment_id)
    return unless comment

    author = comment.user
    followers = author.followers

    followers.find_each do |follower|
      Notification.create!(
        user: follower,
        actor: author,
        action: "new_comment",
        notifiable: comment
      )
    end
  rescue StandardError => e
    Rails.logger.error("NotifyFollowersJob failed for comment #{comment_id}: #{e.message}")
  end
end
