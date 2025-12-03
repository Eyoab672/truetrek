class Comment < ApplicationRecord
  include PgSearch::Model

  belongs_to :place
  belongs_to :user
  has_many_attached :photos

  validates :description, presence: true
  validates :description, length: { minimum: 20 }

  pg_search_scope :search,
    against: [:description],
    using: {
      tsearch: { prefix: true }
    }
end
