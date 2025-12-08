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

  def user_is_local?
    return false unless user&.city.present?

    user.city.downcase.strip == place.city.name.downcase.strip
  end

  # Weighted score for ranking only; display remains the raw vote balance.
  # Local authors get a bonus applied only if the comment has a positive balance.
  def weighted_score(local_bonus: 2)
    base = vote_balance
    bonus = base.positive? && user_is_local? ? local_bonus : 0
    base + bonus
  end

  # Ordering key ensures positives first, then zero, then negative; locals tie-break within groups.
  def ordering_key(local_bonus: 2)
    if vote_balance > 0
      [0, -weighted_score(local_bonus: local_bonus), -created_at.to_i]
    elsif vote_balance == 0
      zero_bonus = user_is_local? ? local_bonus : 0
      [1, -zero_bonus, -created_at.to_i]
    else
      # Negative votes remain at the bottom; more negative is pushed further down.
      [2, vote_balance, -created_at.to_i]
    end
  end

  pg_search_scope :search,
    against: [:description],
    using: {
      tsearch: { prefix: true }
    }
end
