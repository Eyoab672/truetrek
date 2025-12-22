class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in @user, event: :authentication

      if @user.needs_profile_completion?
        redirect_to complete_profile_path, notice: "Please complete your profile to continue."
      else
        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: "Google")
        redirect_to root_path
      end
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end
end
