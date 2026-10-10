# Feedback is internal: only the receiving charity writes it, and only admins
# and that charity can read it. Donors never see it.
class FeedbackPolicy < ApplicationPolicy
  # Once the donation has arrived, and only once per offer
  def create?
    # Ask the database: building the draft feedback sets offer.feedback to it
    owning_charity? && offer.status == "received" && !Feedback.exists?(offer_id: offer.id)
  end

  def new?
    create?
  end

  def update?
    owning_charity? && record.persisted?
  end

  def edit?
    update?
  end

  def show?
    admin? || owning_charity?
  end

  private

  def offer
    record.offer
  end

  def admin?
    user&.admin?
  end

  def owning_charity?
    user&.charity.present? && offer.request.charity_id == user.charity.id
  end
end
