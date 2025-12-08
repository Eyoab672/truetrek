module Admin
  class PlacesController < BaseController
    before_action :set_place, only: [:show, :destroy]

    def index
      @places = Place.includes(:city, :reports).order(created_at: :desc)
      if params[:query].present?
        @places = @places.search(params[:query])
      end
    end

    def show
      @reports = @place.reports.includes(:user).order(created_at: :desc)
    end

    def destroy
      city = @place.city
      @place.destroy
      redirect_to admin_places_path, notice: "Place '#{@place.title}' was successfully deleted."
    end

    private

    def set_place
      @place = Place.find(params[:id])
    end
  end
end
