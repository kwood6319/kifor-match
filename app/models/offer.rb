class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :donor

  has_many_attached :photos

  before_update :resubmit_if_amended, if: :donor_amendment?

  attr_accessor :arrival_day, :arrival_month_year

  before_validation :assemble_estimated_arrival

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

  validate :estimated_arrival_not_in_past
  validate :can_ship_by_not_in_past

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

  def assemble_estimated_arrival
    return if arrival_day.blank? || arrival_month_year.blank?

    year, month = arrival_month_year.split("-").map(&:to_i)
    self.estimated_arrival = Date.new(year, month, arrival_day.to_i)
  rescue ArgumentError
    errors.add(:estimated_arrival, :invalid)
  end

  def estimated_arrival_not_in_past
    return if estimated_arrival.blank?
    return unless estimated_arrival_changed?
    return if estimated_arrival >= Date.current

    errors.add(:estimated_arrival, :in_past)
  end

  # The date comes straight from the form's date picker; only a newly chosen date is checked,
  # so editing an older offer doesn't fail on a ready-from date that has since passed
  def can_ship_by_not_in_past
    return if can_ship_by.blank? || !can_ship_by_changed? || can_ship_by >= Date.current

    errors.add(:can_ship_by, :in_past)
  end

  def resync_request_quantity
    return if request.blank?

    request.sync_quantity_remaining
    request.save!(validate: false)
  end
end
