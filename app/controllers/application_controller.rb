class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_profile_complete
  include Pundit::Authorization

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   redirect_to(root_path)
  # end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username city avatar])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :city, :avatar, travel_book_attributes: [:hidden]])
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ %r{(^(rails_)?admin)|(^pages$)|(^mission_control)|(^places/autocomplete$)}
  end

  def ensure_profile_complete
    return unless user_signed_in?
    return if devise_controller?
    return if params[:controller] == "users/profiles"

    if current_user.needs_profile_completion?
      redirect_to complete_profile_path, alert: "Please complete your profile to continue."
    end
  end
end
