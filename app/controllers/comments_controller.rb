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
        begin
          results = Geocoder.search([lat, lng])
          if results.present? && results.first
            city_name = results.first.city || results.first.state || results.first.country
            @auto_city = City.find_or_create_by(name: city_name) if city_name.present?
            @city = @auto_city if @auto_city
          end
        rescue => e
          Rails.logger.error "Geocoding error: #{e.message}"
        end
      end

      @places = @city.places if @city
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
        rescue => e
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

      redirect_to city_place_path(@place.city, @place), notice: "Photo added successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @place = @comment.place
    authorize @comment

    @comment.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("comment_#{@comment.id}") }
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
