class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :donor

  has_one_attached :photo

  after_update :update_request_quantity

  private

  def update_request_quantity
    return unless saved_change_to_status == ["submitted", "approved"]

    request.update!(quantity_remaining: request.quantity_needed - quantity_offered)
  end
end
