class NotificationsController < ApplicationController
  def index
    @notifications = policy_scope(Notification).recent.includes(:actor, :notifiable)
    authorize Notification

    # Auto-mark all as read when viewing
    current_user.notifications.unread.update_all(read_at: Time.current)
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    authorize @notification
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream
    end
  end

  def mark_all_read
    authorize Notification
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "All notifications marked as read" }
      format.turbo_stream
    end
  end
end
