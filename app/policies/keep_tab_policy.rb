class KeepTabPolicy < ApplicationPolicy
  def create?
    user.present? && user != record.followed
  end

  def destroy?
    user.present? && record.follower == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(follower: user)
    end
  end
end
