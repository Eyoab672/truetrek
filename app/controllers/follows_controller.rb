class FollowsController < ApplicationController
  before_action :set_user

  def create
    @follow = current_user.follows.build(followed: @user)
    authorize @follow

    if @follow.save
      respond_to do |format|
        format.html { redirect_to @user, notice: "You are now following #{@user.username}" }
        format.turbo_stream
      end
    else
      redirect_to @user, alert: @follow.errors.full_messages.join(", ")
    end
  end

  def destroy
    @follow = current_user.follows.find_by(followed: @user)
    authorize @follow

    if @follow&.destroy
      respond_to do |format|
        format.html { redirect_to @user, notice: "You unfollowed #{@user.username}" }
        format.turbo_stream
      end
    else
      redirect_to @user, alert: "Could not unfollow user"
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
