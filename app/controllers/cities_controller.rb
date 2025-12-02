class CitiesController < ApplicationController

  def index
    if params[:query].present?
      @cities = City.where("name ILIKE ?", "%#{params[:query]}%").order(:name)
    else
      @cities = City.order(:name)
    end
  end

  def show
    @city = City.find(params[:id])
  end

end
