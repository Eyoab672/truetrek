class PlacesController < ApplicationController
  before_action :set_place, only: [:show]

  def index
    @places = policy_scope(Place)
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
