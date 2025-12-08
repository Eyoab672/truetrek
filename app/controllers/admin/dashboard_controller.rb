module Admin
  class DashboardController < BaseController
    def index
      @pending_reports_count = Report.pending.count
      @total_reports_count = Report.count
      @places_count = Place.count
      @users_count = User.count
      @comments_count = Comment.count
      @recent_reports = Report.pending.includes(:user, :place).order(created_at: :desc).limit(5)
    end
  end
end
