class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized

  def complete
    # Show form to complete profile (enter city)
  end

  def update_profile
    if current_user.update(profile_params)
      redirect_to root_path, notice: "Welcome to TrueTrek!"
    else
      render :complete, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:city, :username)
  end
end
