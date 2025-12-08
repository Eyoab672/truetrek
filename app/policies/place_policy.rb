class PlacePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def show?
    true
  end

  def regenerate_description?
    true
  end
  
  def destroy?
    user&.admin?
  end

  def edit?
    user&.admin?
  end

  def new?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end
end
