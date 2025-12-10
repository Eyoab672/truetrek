require "open-uri"

class CommentsController < ApplicationController
  def new
    @comment = Comment.new
    @place = Place.new
    authorize @comment

    # If place_id is provided, load that place (user selected from camera flow)
    if params[:place_id]
      @place = Place.find(params[:place_id])
    elsif params[:from_camera]
      # Get city from geolocation for place selection
      lat = session[:captured_latitude]
      lng = session[:captured_longitude]

      if lat.present? && lng.present?
        @place.latitude = lat
        @place.longitude = lng

        begin
          results = Geocoder.search([lat, lng])
          if results.present? && results.first
            result = results.first
            city_name = result.city || result.state || result.country
            @auto_city = City.find_or_create_by(name: city_name) if city_name.present?
            @city = @auto_city if @auto_city
            @place.city = @auto_city if @auto_city
            @place.address = result.address

            # Auto-detect place name from reverse geocoding
            @place.title = result.name ||
                           result.poi ||
                           result.amenity ||
                           result.tourism ||
                           result.building ||
                           result.suburb ||
                           result.neighbourhood ||
                           result.address
          end
        rescue StandardError => e
          Rails.logger.error "Geocoding error: #{e.message}"
        end

        # Find places within 10km of the photo location
        @nearby_places = Place.near([lat, lng], 10, units: :km).order(:title)
      end
    end
  end

  def create
    if params[:place_id]
      # Flow 2: Adding comment to existing place (nested route)
      @place = Place.find(params[:place_id])
      @comment = build_comment
      @is_new_place = false
    else
      # Flow 1: Creating new place with first comment
      @place = Place.new(place_params)
      unless @place.save
        Rails.logger.error "Place save failed: #{@place.errors.full_messages.join(', ')}"
        flash.now[:alert] = @place.errors.full_messages.join(", ")
        @comment = Comment.new(comment_params)
        render :new, status: :unprocessable_entity
        return
      end
      @comment = build_comment
      @is_new_place = true
    end

    authorize @comment

    if @comment.save
      # Attach camera photo if present (camera flow)
      if session[:captured_blob_id].present?
        begin
          blob = ActiveStorage::Blob.find_signed(session[:captured_blob_id])
          @comment.photos.attach(blob) if blob
          session[:captured_blob_id] = nil
          session[:captured_latitude] = nil
          session[:captured_longitude] = nil
        rescue StandardError => e
          Rails.logger.error "Failed to attach camera photo to comment: #{e.message}"
        end
      end


      # Queue async description generation
      user_review = @comment.description.presence || "Visitor review not provided yet."
      username = current_user&.username || "anonymous"

      if @is_new_place
        # Generate initial description for new place (async)
        GeneratePlaceDescriptionJob.perform_later(@place.id, user_review: user_review, username: username)
      else
        # Update description with new comment (async)
        UpdateEnhancedDescriptionJob.perform_later(@place.id)
      end

      # Set flag to show loading skeleton on redirect
      flash[:description_loading] = true
      notice_message = @is_new_place ? "Place created successfully!" : "Comment added successfully!"
      redirect_to city_place_path(@place.city, @place), notice: notice_message

    else
      Rails.logger.error "Comment save failed: #{@comment.errors.full_messages.join(', ')}"
      flash.now[:alert] = @comment.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @place = @comment.place
    authorize @comment

    @comment.destroy

    # Regenerate description after comment/reply deletion
    UpdateEnhancedDescriptionJob.perform_later(@place.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("comment_#{@comment.id}"),
          turbo_stream.replace("place_description", partial: "places/description_loading", locals: { place: @place })
        ]
      end
      format.html { redirect_to city_place_path(@place.city, @place), notice: "Comment deleted." }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:description, photos: [])
  end

  def place_params
    params.require(:place).permit(:title, :city_id, :latitude, :longitude, :address)
  end

  def build_comment
    comment = Comment.new(comment_params)
    comment.place = @place
    comment.user = current_user
    comment
  end
end
