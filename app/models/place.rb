class Place < ApplicationRecord
  belongs_to :city
  geocoded_by :address
  # TODO: Re-enable once geocoder SSL issue is fixed
  # after_validation :geocode, if: :will_save_change_to_address?
end
