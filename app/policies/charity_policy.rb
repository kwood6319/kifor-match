class CharityPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def index?
    admin? || donor?
  end

  def approve?
    admin?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    user&.respond_to?(:role) && user.role == "admin"
  end

  def donor?
    user.present? && Donor.exists?(user_id: user.id)
  end
end
