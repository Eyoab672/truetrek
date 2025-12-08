class CapturePolicy < ApplicationPolicy
  def create?
    user.present?
  end
end
