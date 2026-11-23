class RequestPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.charity
        scope.where(charity: user.charity)
      elsif user.admin?
        scope.all
      else
        # Donors only see needs from approved, active charities
        scope.where(charity: Charity.visible)
      end
    end
  end

  def index?
    true
  end

  # Archived needs are hidden from the public. Donors who offered can still open
  # them, so a rejection notification links somewhere they can read the reason.
  def show?
    return true if user.admin? || record.charity == user.charity || offered_on?

    record.charity.visible? && !record.archived?
  end

  # Unapproved charities are already redirected by require_approval; this
  # backs that up so a charity can never post a need before approval.
  def create?
    user&.charity.present? && user.charity.approved?
  end

  def update?
    record.charity == user.charity && !record.archived?
    # record: the request passed to the `authorize` method in controller
    # user: the `current_user` signed in with Devise
  end

  # A live offer blocks deletion: the charity must reject it first so the donor is notified.
  def destroy?
    record.charity == user.charity && !record.archived? && !record.locked?
  end

  def deactivate?
    record.charity == user.charity
  end

  def archive?
    record.charity == user.charity && record.fully_fulfilled? && !record.archived?
  end

  private

  def offered_on?
    user.donor.present? && record.offers.exists?(donor: user.donor)
  end
end
