class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :donor

  has_many_attached :photos

  before_update :resubmit_if_amended, if: :donor_amendment?

  attr_accessor :ship_by_day, :ship_by_month_year

  before_validation :assemble_can_ship_by

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
  SHIPPED_STATUSES = %w[shipped received flagged completed].freeze

  NOTIFICATION_CLASSES = {
    "completed" => OfferCompletedNotification,
    "rejected" => OfferRejectedNotification
  }.freeze

  ALERT_STATUS_ALIASES = {
    "flagged" => "received"
  }.freeze

  scope :active, -> { where(active: true) }
  scope :unarchived, -> { where(archived_at: nil) }

  SHIPPING_FIELDS = %w[estimated_arrival tracking_number].freeze
  IGNORED_AMENDMENT_FIELDS = %w[status updated_at rejection_reason active archived_at].freeze

  validates :quantity_offered, presence: true, numericality: { only_integer: true, greater_than: 0 }
  # allow_blank so a missing condition only reports "can't be blank"
  validates :condition, presence: true, inclusion: { in: Request::CONDITIONS, allow_blank: true }
  validates :can_ship_by, presence: true
  validates :status, inclusion: { in: STATUSES }

  validate :photos_attached

  validate :quantity_offered_does_not_exceed_remaining

  before_save :set_active_from_status
  after_save :resync_request_quantity, if: :saved_change_to_status?
  after_update :create_terminal_notification, if: :saved_change_to_status?

  def rejected?
    status == "rejected"
  end

  def archived?
    archived_at.present?
  end

  # Donor dismissed a rejected offer. Status stays "rejected" so it can still be shown in history.
  # update_column skips validations/callbacks, so archiving never trips content checks or resubmits the offer.
  def archive!
    update_column(:archived_at, Time.current)
  end

  def shipped_or_later?
    SHIPPED_STATUSES.include?(status)
  end

  def alert_message
    key = ALERT_STATUS_ALIASES.fetch(status, status)
    I18n.t("dashboard.alert_messages.#{key}")
  end

  # What the charity needs to do next, shown on the charity dashboard tracker
  def charity_alert_message
    key = ALERT_STATUS_ALIASES.fetch(status, status)
    I18n.t("dashboard.charity_alert_messages.#{key}")
  end

  private

  def donor_amendment?
    %w[approved rejected].include?(status_was) &&
      (changes.keys - IGNORED_AMENDMENT_FIELDS - SHIPPING_FIELDS).any?
  end

  def resubmit_if_amended
    self.status = "submitted"
  end

  def photos_attached
    errors.add(:base, :photos_missing) unless photos.attached?
  end

  def set_active_from_status
    self.active = !TERMINAL_STATUSES.include?(status)
  end

  def create_terminal_notification
    notification_class = NOTIFICATION_CLASSES[status]
    return unless notification_class

    notification_class.create!(recipient: donor, offer: self)
  end

  # To do: consider edge case of if charity updates quantity_needed.
  def quantity_offered_does_not_exceed_remaining
    return if request.blank? || quantity_offered.blank?

    allowed = request.quantity_remaining
    allowed += quantity_offered_was.to_i if persisted? && quantity_offered_was.present?

    return if quantity_offered <= allowed

    errors.add(:quantity_offered, :exceeds_remaining, max: allowed)
  end

  def assemble_can_ship_by
    return if ship_by_day.blank? || ship_by_month_year.blank?

    year, month = ship_by_month_year.split("-").map(&:to_i)

    begin
      date = Date.new(year, month, ship_by_day.to_i)
    rescue ArgumentError
      # Date::Error is a subclass of ArgumentError, so rescuing
      # ArgumentError alone covers both without shadowing.
      errors.add(:can_ship_by, :invalid_date, message: I18n.t("offers.errors.invalid_ship_date"))
      return
    end

    if date < Date.current
      errors.add(:can_ship_by, :in_the_past, message: I18n.t("offers.errors.ship_date_in_past"))
      return
    end

    self.can_ship_by = date
  end

  def resync_request_quantity
    return if request.blank?

    request.sync_quantity_remaining
    request.save!(validate: false)
  end
end
