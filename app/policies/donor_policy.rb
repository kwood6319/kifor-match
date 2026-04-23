class DonorPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def index?
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
