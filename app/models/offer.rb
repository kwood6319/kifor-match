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
    flagged
    completed
  ].freeze

  TERMINAL_STATUSES = %w[rejected completed]

  NOTIFICATION_CLASSES = {
    "completed" => OfferCompletedNotification,
    "rejected" => OfferRejectedNotification
  }.freeze

  ALERT_STATUS_ALIASES = {
    "flagged" => "received"
  }.freeze

  validates :status, inclusion: { in: STATUSES }
  validates :condition, inclusion: { in: Request::CONDITIONS }

  scope :active, -> { where(active: true) }

  SHIPPING_FIELDS = %w[estimated_arrival tracking_number].freeze

  validates :quantity_offered, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :condition, presence: true, inclusion: { in: Request::CONDITIONS }
  validates :can_ship_by, presence: true
  validates :photo, presence: true
  validates :status, inclusion: { in: STATUSES }
  before_save :set_active_from_status
  after_update :create_terminal_notification, if: :saved_change_to_status?

  def alert_message
    key = ALERT_STATUS_ALIASES.fetch(status, status)
    I18n.t("dashboard.alert_messages.#{key}")
  end

  private

  def donor_amendment?
    %w[approved rejected]
      .include?(status_was) && (changes.keys - ["status", "updated_at", "rejection_reason"] - SHIPPING_FIELDS).any?
  end

  def resubmit_if_amended
    self.status = "submitted"
  end

  def update_request_quantity
    return unless saved_change_to_status == ["submitted", "approved"]

    request.update!(quantity_remaining: request.quantity_needed - quantity_offered)
  end

  def set_active_from_status
    self.active = !TERMINAL_STATUSES.include?(status)
  end

  def create_terminal_notification
    notification_class = NOTIFICATION_CLASSES[status]
    return unless notification_class

    notification_class.create!(recipient: donor, offer: self)
  end
end
