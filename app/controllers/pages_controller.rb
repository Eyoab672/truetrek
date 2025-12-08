class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @places = Place.all
    @markers = @places.geocoded.map do |place|
      {
        lat: place.latitude,
        lng: place.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {place: place})
      }
    end

    # Geocode user's city for initial map center
    if user_signed_in? && current_user.city.present?
      coordinates = Geocoder.coordinates(current_user.city)
      @user_center = coordinates.reverse if coordinates # [lng, lat] format for Mapbox
    end
  end
end
