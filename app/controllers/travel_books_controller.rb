class TravelBooksController < ApplicationController
  def show
    @travel_book = current_user.travel_book || current_user.create_travel_book
    authorize @travel_book
  end
end
