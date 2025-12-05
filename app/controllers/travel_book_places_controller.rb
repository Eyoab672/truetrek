class TravelBookPlacesController < ApplicationController
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
end
