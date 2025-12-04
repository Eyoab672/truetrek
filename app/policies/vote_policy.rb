class VotePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
  end

  def create?
    user.present?
  end

  def destroy?
    record.user == user
  end
end
