class OfferPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      return scope.none unless user

      if user.respond_to?(:role) && user.role == "admin"
        scope.all
      elsif (donor = Donor.find_by(user_id: user.id))
        scope.where(donor_id: donor.id)
      elsif (charity = Charity.find_by(user_id: user.id))
        scope.joins(:request).where(requests: { charity_id: charity.id })
      else
        scope.none
      end
    end
  end

  def index?
    true
  end

  def search?
    true
  end

  def show?
    admin? || owning_donor? || owning_charity?
  end

  def create?
    admin? || donor.present?
  end

  def destroy?
    admin? || owning_donor?
  end

  def approve?
    admin? || owning_charity?
  end

  def reject?
    admin? || owning_charity?
  end

  def mark_received?
    admin? || owning_charity?
  end

  def mark_as_shipped?
    admin? || owning_donor?
  end

  private

  def admin?
    user&.respond_to?(:role) && user.role == "admin"
  end

  def donor
    @donor ||= user && Donor.find_by(user_id: user.id)
  end

  def charity
    @charity ||= user && Charity.find_by(user_id: user.id)
  end

  def owning_donor?
    donor.present? && record.donor_id == donor.id
  end

  def owning_charity?
    charity.present? && record.request.charity_id == charity.id
  end
end
