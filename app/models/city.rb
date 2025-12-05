class City < ApplicationRecord
  include PgSearch::Model

  has_many :places
  has_one_attached :photo

  pg_search_scope :search,
    against: [:name],
    using: {
      tsearch: { prefix: true }
    }

  def self.closest_to(lat, lng)
    return nil if lat.blank? || lng.blank?

    lat = lat.to_f
    lng = lng.to_f

    all.min_by do |city|
      distance_between(lat, lng, city.latitude.to_f, city.longitude.to_f)
    end
  end

  # Haversine distance in km
  def self.distance_between(lat1, lng1, lat2, lng2)
    rad = Math::PI / 180
    r = 6371 # Earth radius in km

    dlat = (lat2 - lat1) * rad
    dlng = (lng2 - lng1) * rad

    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat1 * rad) * Math.cos(lat2 * rad) *
        Math.sin(dlng / 2)**2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    r * c
  end
end
