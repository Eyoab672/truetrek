class TravelBookPlacesController < ApplicationController
  skip_after_action :verify_authorized, only: [:bulk_destroy, :bulk_pin, :toggle_pin]

  def create
    @place = Place.find(params[:place_id])
    @travel_book = current_user.travel_book || current_user.create_travel_book
    @travel_book_place = @travel_book.travel_book_places.build(place: @place)
    authorize @travel_book_place

    if @travel_book_place.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: city_place_path(@place.city, @place), notice: "Place added to your Travel Book!" }
      end
    else
      redirect_back fallback_location: city_place_path(@place.city, @place), alert: "Could not add place to Travel Book."
    end
  end

  def destroy
    @travel_book_place = TravelBookPlace.find(params[:id])
    @place = @travel_book_place.place
    authorize @travel_book_place

    @travel_book_place.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: my_travel_book_path, notice: "Place removed from your Travel Book." }
    end
  end

  def bulk_destroy
    travel_book = current_user.travel_book
    return head :not_found unless travel_book

    ids = params[:ids] || []
    travel_book_places = travel_book.travel_book_places.where(id: ids)
    travel_book_places.destroy_all

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to my_travel_book_path, notice: "#{ids.size} place(s) removed from your Travel Book." }
    end
  end

  def bulk_pin
    travel_book = current_user.travel_book
    return head :not_found unless travel_book

    ids = params[:ids] || []

    # Check if total pinned would exceed limit
    current_pinned = travel_book.travel_book_places.pinned.where.not(id: ids).count
    if current_pinned + ids.size > TravelBookPlace::MAX_PINNED
      return render json: { error: "You can only pin up to #{TravelBookPlace::MAX_PINNED} places" }, status: :unprocessable_entity
    end

    travel_book.travel_book_places.where(id: ids).update_all(pinned: true)

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to my_travel_book_path, notice: "#{ids.size} place(s) pinned." }
    end
  end

  def toggle_pin
    @travel_book_place = current_user.travel_book&.travel_book_places&.find(params[:id])
    return head :not_found unless @travel_book_place

    if @travel_book_place.pinned?
      @travel_book_place.unpin!
      message = "Place unpinned."
    else
      if @travel_book_place.pin!
        message = "Place pinned."
      else
        respond_to do |format|
          format.json { render json: { error: @travel_book_place.errors.full_messages.join(", ") }, status: :unprocessable_entity }
          format.html { redirect_to my_travel_book_path, alert: @travel_book_place.errors.full_messages.join(", ") }
        end
        return
      end
    end

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to my_travel_book_path, notice: message }
    end
  end
end
