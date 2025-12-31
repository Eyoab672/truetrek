class ConversationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    return false unless user.present?
    return record.is_member?(user) if record.group?
    record.sender == user || record.recipient == user
  end

  def new?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    return false unless user.present?
    record.group? && record.is_admin?(user)
  end

  def accept?
    user.present? && !record.group? && record.recipient == user && !record.accepted?
  end

  def decline?
    user.present? && !record.group? && record.recipient == user && !record.accepted?
  end

  def info?
    show?
  end

  def add_members?
    return false unless user.present?
    record.group? && record.is_admin?(user)
  end

  def remove_member?
    return false unless user.present?
    record.group? && record.is_member?(user)
  end

  def leave?
    return false unless user.present?
    record.group? && record.is_member?(user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.for_user(user)
    end
  end
end
