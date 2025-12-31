class Conversation < ApplicationRecord
  # DM associations (for backward compatibility)
  belongs_to :sender, class_name: "User", optional: true
  belongs_to :recipient, class_name: "User", optional: true

  # Group chat associations
  belongs_to :created_by, class_name: "User", optional: true
  has_many :conversation_members, dependent: :destroy
  has_many :members, through: :conversation_members, source: :user
  has_many :active_members, -> { where(conversation_members: { left_at: nil }) },
           through: :conversation_members, source: :user

  has_many :messages, dependent: :destroy
  has_one_attached :group_avatar

  # Scopes
  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }
  scope :groups, -> { where(is_group: true) }
  scope :direct_messages, -> { where(is_group: false) }
  scope :for_user, ->(user) {
    # Get IDs for DMs where user is sender or recipient
    dm_ids = where(is_group: false)
              .where("sender_id = ? OR recipient_id = ?", user.id, user.id)
              .pluck(:id)

    # Get IDs for groups where user is an active member
    group_ids = joins(:conversation_members)
                 .where(is_group: true)
                 .where(conversation_members: { user_id: user.id, left_at: nil })
                 .pluck(:id)

    where(id: dm_ids + group_ids)
  }

  # Validations
  validates :sender_id, uniqueness: { scope: :recipient_id }, if: -> { !is_group && sender_id.present? }
  validate :cannot_message_self, unless: :is_group
  validate :group_must_have_members, if: :is_group
  validates :group_name, length: { maximum: 100 }, allow_blank: true

  # Group chat methods
  def group?
    is_group
  end

  def direct_message?
    !is_group
  end

  def display_name(for_user = nil)
    if is_group
      group_name.presence || members.where.not(id: for_user&.id).limit(3).pluck(:username).join(", ")
    else
      other_user(for_user)&.username
    end
  end

  def add_member(user, role: :member)
    return false if is_member?(user)
    conversation_members.create(user: user, role: role, joined_at: Time.current)
  end

  def remove_member(user)
    conversation_members.find_by(user: user)&.leave!
  end

  def is_member?(user)
    conversation_members.active.exists?(user: user)
  end

  def is_admin?(user)
    conversation_members.active.admins.exists?(user: user)
  end

  def active_member_count
    conversation_members.active.count
  end

  def admins
    active_members.joins(:conversation_members).where(conversation_members: { role: :admin })
  end

  # DM methods (backward compatibility)
  def mutual_follow?
    return false if is_group
    sender.following?(recipient) && recipient.following?(sender)
  end

  def auto_accept_if_mutual!
    return if is_group
    update!(accepted: true, accepted_at: Time.current) if mutual_follow? && !accepted?
  end

  def other_user(user)
    return nil if is_group
    user == sender ? recipient : sender
  end

  def can_send_message?(user)
    if is_group
      is_member?(user)
    else
      return true if accepted? || mutual_follow?
      return true if user == sender && messages.count == 0
      false
    end
  end

  def accept!
    update!(accepted: true, accepted_at: Time.current) unless is_group
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def unread_count_for(user)
    messages.where.not(user: user).where(read_at: nil).count
  end

  # Class methods for creating conversations
  def self.find_or_create_dm(user1, user2)
    # Find existing DM between the two users
    conversation = where(is_group: false)
                    .where("(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)",
                           user1.id, user2.id, user2.id, user1.id)
                    .first

    return conversation if conversation

    # Create new DM
    create!(
      sender: user1,
      recipient: user2,
      is_group: false,
      accepted: user1.following?(user2) && user2.following?(user1)
    )
  end

  def self.create_group(creator:, member_ids:, name: nil)
    transaction do
      conversation = create!(
        is_group: true,
        group_name: name,
        created_by: creator,
        accepted: true
      )

      # Add creator as admin
      conversation.conversation_members.create!(
        user: creator,
        role: :admin,
        joined_at: Time.current
      )

      # Add other members
      User.where(id: member_ids).where.not(id: creator.id).find_each do |user|
        conversation.conversation_members.create!(
          user: user,
          role: :member,
          joined_at: Time.current
        )
      end

      conversation
    end
  end

  private

  def cannot_message_self
    return if is_group
    errors.add(:recipient, "can't message yourself") if sender_id == recipient_id
  end

  def group_must_have_members
    return unless is_group && new_record?
    # Validation happens after members are added, so we skip for new records
  end
end
