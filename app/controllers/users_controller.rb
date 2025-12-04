class UsersController < ApplicationController
  skip_after_action :verify_authorized, only: [:search]
  skip_after_action :verify_policy_scoped, only: [:search]

  def show
    @user = User.find(params[:id])
    authorize @user
    @comments = @user.comments.includes(:place, photos_attachments: :blob).order(created_at: :desc)
    @travel_book = @user.travel_book
    @places_count = @travel_book&.places&.count || 0
  end

  def search
    query = params[:q].to_s.strip
    if query.present?
      @users = User.where("username ILIKE ?", "%#{query}%").limit(5)
    else
      @users = User.none
    end

    render json: @users.map { |u| { id: u.id, username: u.username } }
  end
end
