class PlacesController < ApplicationController
  before_action :set_place, only: [:show]

  def index
    @city = City.find(params[:city_id])
    @places = policy_scope(@city.places)
    @places = @places.search(params[:query]) if params[:query].present?
  end

  def new
    @place = Place.new

    @camera_blob_id = session[:captured_blob_id]
    lat = session[:captured_latitude]
    lng = session[:captured_longitude]

    return unless lat.present? && lng.present?

    @auto_city = City.closest_to(lat, lng)
    @place.city = @auto_city if @auto_city
  end

  def show
    @comment = Comment.new
    @comments = @place.comments.includes(:user, :votes).where(parent_id: nil).sort_by do |c|
      c.ordering_key(local_bonus: 2)
    end
    @markers =
      [{
        lat: @place.latitude,
        lng: @place.longitude
      }]
  end

  def create
    @place = Place.new(place_params)

    if @place.camera_blob_id.present? && (blob = ActiveStorage::Blob.find_signed(@place.camera_blob_id))
      @place.photo.attach(blob)
    end

    if @place.save
      # clear camera session
      session[:captured_blob_id] = nil
      session[:captured_latitude] = nil
      session[:captured_longitude] = nil

      redirect_to @place, notice: "Place created!"
    else
      @camera_blob_id = session[:captured_blob_id]
      lat = session[:captured_latitude]
      lng = session[:captured_longitude]
      @auto_city = City.closest_to(lat, lng) if lat.present? && lng.present?
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_place
    @place = Place.find(params[:id])
    authorize @place
  end

  def place_params
    params.require(:place).permit(
      :title,
      :enhanced_description,
      :address,
      :city_id,
      :camera_blob_id
    )
  end
end
