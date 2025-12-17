class ConversationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (record.sender == user || record.recipient == user)
  end

  def create?
    user.present? && user != record.recipient
  end

  def accept?
    user.present? && record.recipient == user && !record.accepted?
  end

  def decline?
    user.present? && record.recipient == user && !record.accepted?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.for_user(user)
    end
  end
end
