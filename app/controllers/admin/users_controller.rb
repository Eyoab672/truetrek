module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :ban, :unban, :destroy]

    def index
      @users = User.order(created_at: :desc)
      @users = @users.where(banned: true) if params[:filter] == "banned"
      @users = @users.where(admin: true) if params[:filter] == "admins"

      if params[:query].present?
        @users = @users.where("username ILIKE :q OR email ILIKE :q", q: "%#{params[:query]}%")
      end
    end

    def show
      @comments = @user.comments.includes(:place).order(created_at: :desc).limit(10)
    end

    def ban
      if @user.admin?
        redirect_to admin_users_path, alert: "Cannot ban an admin user."
        return
      end

      reason = params[:reason].presence || "Banned by admin"
      @user.ban!(reason: reason)

      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: "#{@user.username} has been banned." }
        format.turbo_stream
      end
    end

    def unban
      @user.unban!

      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: "#{@user.username} has been unbanned." }
        format.turbo_stream
      end
    end

    def destroy
      if @user.admin?
        redirect_to admin_users_path, alert: "Cannot delete an admin user."
        return
      end

      username = @user.username
      @user.destroy
      redirect_to admin_users_path, notice: "User #{username} has been deleted."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
