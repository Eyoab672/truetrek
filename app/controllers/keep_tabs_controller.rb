class KeepTabsController < ApplicationController
  before_action :set_user

  def create
    @keep_tab = current_user.keep_tabs.build(followed: @user)
    authorize @keep_tab

    if @keep_tab.save
      respond_to do |format|
        format.html { redirect_to @user, notice: "You are now keeping tabs on #{@user.username}" }
        format.turbo_stream
      end
    else
      redirect_to @user, alert: @keep_tab.errors.full_messages.join(", ")
    end
  end

  def destroy
    @keep_tab = current_user.keep_tabs.find_by(followed: @user)
    authorize @keep_tab

    if @keep_tab&.destroy
      respond_to do |format|
        format.html { redirect_to @user, notice: "You stopped keeping tabs on #{@user.username}" }
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
