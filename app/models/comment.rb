class Comment < ApplicationRecord
  include PgSearch::Model

  belongs_to :place
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many_attached :photos

  validates :description, presence: true
  validates :description, length: { minimum: 20 }

  pg_search_scope :search,
    against: [:description],
    using: {
      tsearch: { prefix: true }
    }
end
