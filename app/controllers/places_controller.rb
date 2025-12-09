class PlacesController < ApplicationController
  before_action :set_place, only: %i[show regenerate_description destroy]

  def index
    @city = City.find(params[:city_id])
    @places = policy_scope(@city.places)
    @places = @places.search(params[:query]) if params[:query].present?
  end

  def new
    @place = Place.new
    authorize @place

    @camera_blob_id = session[:captured_blob_id]
    lat = session[:captured_latitude]
    lng = session[:captured_longitude]

    if lat.present? && lng.present?
      @place.latitude = lat
      @place.longitude = lng

      # Reverse geocode to get city and address
      begin
        results = Geocoder.search([lat, lng])
        if results.present? && results.first
          city_name = results.first.city || results.first.state || results.first.country
          @auto_city = City.find_or_create_by(name: city_name) if city_name.present?
          @place.city = @auto_city if @auto_city
          @place.address = results.first.address
        end
      rescue => e
        Rails.logger.error "Geocoding error: #{e.message}"
      end
    end
  end

  def show
    @comment = Comment.new

    # Combine place photos and comment photos
    @place_photos = @place.photo.map(&:blob)
    @comment_photos = @place.comments.flat_map { |c| c.photos.map(&:blob) }
    @all_photos = @place_photos + @comment_photos

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
    authorize @place

    if @place.save
      # Attach photo from camera blob after saving
      if @place.camera_blob_id.present?
        begin
          blob = ActiveStorage::Blob.find_signed(@place.camera_blob_id)
          @place.photo.attach(blob) if blob
          Rails.logger.info "Photo attached successfully to place #{@place.id}: blob #{blob&.id}"
        rescue => e
          Rails.logger.error "Failed to attach photo to place #{@place.id}: #{e.message}"
        end
      end
    if @place.camera_blob_id.present? && (blob = ActiveStorage::Blob.find_signed(@place.camera_blob_id))
      @place.photo.attach(blob)
    end

      # clear camera session
      session[:captured_blob_id] = nil
      session[:captured_latitude] = nil
      session[:captured_longitude] = nil

      redirect_to city_place_path(@place.city, @place), notice: "Place created!"
    else
      @camera_blob_id = session[:captured_blob_id]
      lat = session[:captured_latitude]
      lng = session[:captured_longitude]

      # Re-populate form data on validation error
      if lat.present? && lng.present?
        begin
          results = Geocoder.search([lat, lng])
          if results.present? && results.first
            city_name = results.first.city || results.first.state || results.first.country
            @auto_city = City.find_or_create_by(name: city_name) if city_name.present?
          end
        rescue => e
          Rails.logger.error "Geocoding error: #{e.message}"
        end
      end

      render :new, status: :unprocessable_entity
    end
  end

  def regenerate_description
    # Queue the job to regenerate asynchronously
    UpdateEnhancedDescriptionJob.perform_later(@place.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "place_description",
          partial: "places/description_loading",
          locals: { place: @place }
        )
      end
      format.html { redirect_to city_place_path(@place.city, @place), notice: "Description is being regenerated..." }
    end
  end
  
  def destroy
    city = @place.city
    @place.destroy
    redirect_to city_places_path(city), notice: "Place was successfully deleted."
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
