class SearchController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @query = params[:query]
    @type = params[:type] || "all"

    return unless @query.present?

    case @type
    when "people"
      @users = User.search(@query).where(banned: false).limit(20)
    when "places"
      @places = Place.search(@query).includes(:city).limit(20)
    when "posts"
      @comments = Comment.search(@query).includes(:place, :user).limit(20)
    else # "all"
      @users = User.search(@query).where(banned: false).limit(6)
      @places = Place.search(@query).includes(:city).limit(6)
      @comments = Comment.search(@query).includes(:place, :user).limit(6)
    end
  end
end
