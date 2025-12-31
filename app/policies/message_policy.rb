class MessagePolicy < ApplicationPolicy
  def create?
    return false unless user.present?

    conversation = record.conversation
    if conversation.group?
      conversation.is_member?(user)
    else
      conversation.sender == user || conversation.recipient == user
    end
  end

  def destroy?
    return false unless user.present?

    record.owned_by?(user) && record.can_unsend?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Get DM message IDs
      dm_messages = scope.joins(:conversation)
                         .where(conversations: { is_group: false })
                         .where("conversations.sender_id = ? OR conversations.recipient_id = ?", user.id, user.id)

      # Get group message IDs
      group_messages = scope.joins(conversation: :conversation_members)
                            .where(conversations: { is_group: true })
                            .where(conversation_members: { user_id: user.id, left_at: nil })

      scope.where(id: dm_messages.pluck(:id) + group_messages.pluck(:id))
    end
  end
end
