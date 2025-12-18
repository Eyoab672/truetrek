class Place < ApplicationRecord
  include PgSearch::Model

  belongs_to :city
  has_many :comments, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many_attached :photo
  geocoded_by :address

  attr_accessor :camera_blob_id   # 👈 add this

  validates :title, presence: true

  pg_search_scope :search,
    against: [:title, :enhanced_description],
    associated_against: {
      comments: [:description]
    },
    using: {
      tsearch: { prefix: true }
    }
  # TODO: Re-enable once geocoder SSL issue is fixed

  after_validation :geocode, if: :will_save_change_to_address?
end
