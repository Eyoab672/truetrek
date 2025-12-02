class Comment < ApplicationRecord
  belongs_to :place
  belongs_to :user
  has_many_attached :photos

  validates :description, presence: true
  validates :description, length: { minimum: 100 }
  
end
