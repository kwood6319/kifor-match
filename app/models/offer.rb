class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :donor

  has_one_attached :photo

  before_update :resubmit_if_amended, if: :donor_amendment?

  STATUSES = %w[
    submitted
    approved
    rejected
    shipped
    received
    sent
  ].freeze

  private

  def donor_amendment?
    %w[approved rejected].include?(status) && (changes.keys - ["status", "updated_at"]).any?
  end

  def resubmit_if_amended
    self.status = "submitted"
  end

  def update_request_quantity
    return unless saved_change_to_status == ["submitted", "approved"]

    request.update!(quantity_remaining: request.quantity_needed - quantity_offered)
  end
end
