class CitiesController < ApplicationController

  def index
    @cities = policy_scope(City)
    if params[:query].present?
      @cities = City.where("name ILIKE ?", "%#{params[:query]}%").order(:name)
    else
      @cities = City.order(:name)
    end
  end
end
