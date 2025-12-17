class MessagePolicy < ApplicationPolicy
  def create?
    return false unless user.present?

    conversation = record.conversation
    conversation.sender == user || conversation.recipient == user
  end

  def destroy?
    return false unless user.present?

    record.owned_by?(user) && record.can_unsend?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:conversation).where(
        "conversations.sender_id = ? OR conversations.recipient_id = ?",
        user.id, user.id
      )
    end
  end
end
