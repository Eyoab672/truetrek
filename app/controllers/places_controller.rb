class PlacesController < ApplicationController
  def new
    @place = Place.new

    @camera_blob_id = session[:captured_blob_id]
    lat = session[:captured_latitude]
    lng = session[:captured_longitude]

    if lat.present? && lng.present?
      @auto_city = City.closest_to(lat, lng)
      @place.city = @auto_city if @auto_city
    end
  end

  def create
    @place = Place.new(place_params)

    if @place.camera_blob_id.present?
      if (blob = ActiveStorage::Blob.find_signed(@place.camera_blob_id))
        @place.photo.attach(blob)
      end
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
