class PlacesController < ApplicationController
  before_action :set_place, only: [:show]

  def index
    @city = City.find(params[:city_id])
    @places = policy_scope(@city.places)
  end

  def show
    @comment = Comment.new
    @markers =
    [{
      lat: @place.latitude,
      lng: @place.longitude
    }]
  end

  private

  def set_place
    @place = Place.find(params[:id])
    authorize @place
  end

end
