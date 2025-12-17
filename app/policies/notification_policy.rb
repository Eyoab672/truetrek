class NotificationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def mark_read?
    user.present? && record.user == user
  end

  def mark_all_read?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end
