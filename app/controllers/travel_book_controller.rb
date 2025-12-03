class TravelBookController < ApplicationController

  # REMEMBER TO AUTHORIZE for pundit
  before_action :authenticate_user!

  def show
    @travel_book = current_user.travel_books.find(params[:id])
    @places_by_city = @travel_book.places.group_by(&:city)
  end

  def add_place
    @travel_book = current_user.travel_books.find(params[:id])
    place = Place.find(params[:place_id])

    @travel_book.places << place

    redirect_to travel_book_path(@travel_book), notice: "Place added to your Travel Book!"
  end

  def remove_place
    @travel_book = current_user.travel_books.find(params[:id])
    place = Place.find(params[:place_id])

    # Remove place from travel book
    @travel_book.places.delete(place)

    redirect_to travel_book_path(@travel_book), notice: "Place removed from your Travel Book."
  end
end
