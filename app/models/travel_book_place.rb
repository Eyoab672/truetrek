class TravelBookPlace < ApplicationRecord
  belongs_to :place
  belongs_to :travel_book

  scope :pinned, -> { where(pinned: true) }
  scope :unpinned, -> { where(pinned: false) }
  scope :ordered, -> { order(pinned: :desc, created_at: :desc) }

  MAX_PINNED = 5

  validate :max_pinned_limit, if: :pinned?

  def pin!
    update(pinned: true)
  end

  def unpin!
    update(pinned: false)
  end

  private

  def max_pinned_limit
    return unless travel_book

    current_pinned_count = travel_book.travel_book_places.pinned.where.not(id: id).count
    if current_pinned_count >= MAX_PINNED
      errors.add(:base, "You can only pin up to #{MAX_PINNED} places")
    end
  end
end
