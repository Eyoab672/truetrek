class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :travel_book, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_one_attached :avatar

  validates :username, presence: true
  validates :city, presence: true

  def admin?
    admin
  end

  def banned?
    banned
  end

  # Devise override: prevent banned users from signing in
  def active_for_authentication?
    super && !banned?
  end

  # Custom message shown to banned users
  def inactive_message
    banned? ? :banned : super
  end

  # Convenience method for banning
  def ban!(reason: nil)
    update!(banned: true, banned_at: Time.current, banned_reason: reason)
  end

  # Convenience method for unbanning
  def unban!
    update!(banned: false, banned_at: nil, banned_reason: nil)
  end
end
