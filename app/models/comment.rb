class Comment < ApplicationRecord
  include PgSearch::Model

  belongs_to :place
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many_attached :photos

  validates :description, presence: true
  validates :description, length: { minimum: 20 }

  def vote_balance
    votes.sum(:value)
  end

  def positive_vote_balance?
    vote_balance > 0
  end

  def user_vote(user)
    return nil unless user
    votes.find_by(user: user)
  end

  pg_search_scope :search,
    against: [:description],
    using: {
      tsearch: { prefix: true }
    }
end
