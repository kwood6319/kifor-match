class DonorPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all.order(created_at: :desc)
    end
  end

  def index?
    admin?
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
end
