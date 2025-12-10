class Places::AutocompleteController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    query = params[:query].to_s.strip
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f

    if query.blank?
      render json: { suggestions: [] }
      return
    end

    begin
      # Sanitize query for LIKE
      sanitized_query = "%#{ActiveRecord::Base.sanitize_sql_like(query.downcase)}%"

      # If we have valid coordinates, prioritize nearby places
      if latitude.nonzero? && longitude.nonzero?
        # Get nearby places within 1km of the location that match the query
        # Use select instead of pluck to avoid issues with Geocoder's distance column
        places = Place.near([latitude, longitude], 1, units: :km)
                      .where("LOWER(title) LIKE ?", sanitized_query)
                      .limit(5)
                      .select(:id, :title, :address, :latitude, :longitude)
      else
        # No coordinates, search all places
        places = Place.where("LOWER(title) LIKE ?", sanitized_query)
                      .limit(5)
                      .select(:id, :title, :address, :latitude, :longitude)
      end

      suggestions = places.map do |place|
        {
          title: place.title,
          address: place.address,
          latitude: place.latitude,
          longitude: place.longitude
        }
      end

      render json: { suggestions: suggestions }
    rescue StandardError => e
      Rails.logger.error "Autocomplete error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { suggestions: [] }, status: :ok
    end
  end
end
