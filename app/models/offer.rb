class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :donor

  has_many_attached :photos
  has_one :feedback, dependent: :destroy

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

  DELIVERY_METHODS = %w[shipping drop_off].freeze

  SHIPPING_FIELDS = %w[estimated_arrival estimated_arrival_time drop_off_time tracking_number].freeze

  # Standard Japanese courier delivery windows (Yamato, Sagawa, Japan Post)
  ARRIVAL_TIME_SLOTS = %w[morning 14_16 16_18 18_20 19_21].freeze
  IGNORED_AMENDMENT_FIELDS = %w[status updated_at rejection_reason active archived_at].freeze

  validates :quantity_offered, presence: true, numericality: { only_integer: true, greater_than: 0 }
  # allow_blank so a missing condition only reports "can't be blank"
  validates :condition, presence: true, inclusion: { in: Request::CONDITIONS, allow_blank: true }
  validates :can_ship_by, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :delivery_method, inclusion: { in: DELIVERY_METHODS }
  validate :delivery_method_available, if: -> { new_record? || will_save_change_to_delivery_method? }
  validates :estimated_arrival_time, inclusion: { in: ARRIVAL_TIME_SLOTS }, allow_blank: true

  validate :photos_attached
  # The request page shows a donor one offer per need; also stops a double-submitted form
  validate :one_offer_per_request, on: :create

  validate :quantity_offered_does_not_exceed_remaining

  validate :estimated_arrival_not_in_past
  # Planned drop-offs: a time, on a day and within the hours the charity takes them
  validate :drop_off_within_hours, if: lambda {
    drop_off? && estimated_arrival.present? &&
      (will_save_change_to_estimated_arrival? || will_save_change_to_drop_off_time?)
  }

  before_save :set_active_from_status
  # Approval is when the donor first sees where to send it, so fix the details then.
  # A re-approval (after the donor amends the offer) takes a fresh copy.
  before_save :snapshot_delivery_details, if: -> { will_save_change_to_status?(to: "approved") }
  after_save :resync_request_quantity, if: :saved_change_to_status?
  after_update :create_terminal_notification, if: :saved_change_to_status?

  def rejected?
    status == "rejected"
  end

  def drop_off?
    delivery_method == "drop_off"
  end

  # Where to send/bring this offer, as it was when approved (unsaved Address).
  # Offers approved before snapshots existed fall back to the charity's current address.
  def delivery_address
    snapshot = delivery_details&.dig("address")
    snapshot ? Address.new(snapshot) : request.charity.address
  end

  # Drop-off days/hours as they were when approved (unsaved DropOffWindows), same fallback
  def delivery_drop_off_windows
    snapshot = delivery_details&.dig("drop_off_windows")
    return request.charity.drop_off_windows.to_a unless snapshot

    snapshot.map { |window| DropOffWindow.new(window) }
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

  # Checked only when the donor picks a method, so a later change to the charity's
  # settings doesn't make existing offers invalid
  def delivery_method_available
    return if request.blank? || request.delivery_methods.include?(delivery_method)

    errors.add(:delivery_method, :unavailable)
  end

  # Checked against the hours saved on the offer at approval (what the donor was shown)
  def drop_off_within_hours
    return errors.add(:base, :drop_off_time_missing) if drop_off_time.blank?

    windows = delivery_drop_off_windows
    return if windows.empty? # no hours on record: the donor is told to check with the charity

    window = windows.find { |w| w.day_of_week == estimated_arrival.wday }
    unless window
      return errors.add(:base, :drop_off_closed_day, day: I18n.t("date.day_names")[estimated_arrival.wday])
    end

    opens, closes = [window.opens_at, window.closes_at].map { |time| time.strftime("%H:%M") }
    planned = drop_off_time.strftime("%H:%M")
    return errors.add(:base, :drop_off_time_interval) unless drop_off_time.min.in?([0, 30]) # form offers :00 / :30
    return if planned >= opens && planned < closes # from opening, up to (not at) closing

    # Shown like the hours elsewhere ("9:00–17:00")
    errors.add(:base, :outside_drop_off_hours, hours: [opens, closes].map { |time| time.delete_prefix("0") }.join("–"))
  end

  def one_offer_per_request
    return if donor.blank? || request.blank?
    return unless Offer.exists?(donor: donor, request: request)

    errors.add(:base, :already_offered)
  end

  def photos_attached
    errors.add(:base, :photos_missing) unless photos.attached?
  end

  def snapshot_delivery_details
    charity = request.charity
    address = charity.address&.slice(*Address::FORM_FIELDS.map(&:to_s))
    # Store the name that goes on the label, so a later org name change doesn't alter it either
    address&.[]=("recipient_name", address["recipient_name"].presence || charity.org_name)
    self.delivery_details = {
      "address" => address,
      "drop_off_windows" => (drop_off_window_details(charity) if drop_off?)
    }.compact
  end

  def drop_off_window_details(charity)
    charity.drop_off_windows.map do |window|
      { "day_of_week" => window.day_of_week,
        "opens_at" => window.opens_at.strftime("%H:%M"),
        "closes_at" => window.closes_at.strftime("%H:%M") }
    end
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

  def estimated_arrival_not_in_past
    return if estimated_arrival.blank?
    return unless estimated_arrival_changed?
    return if estimated_arrival >= Date.current

    errors.add(:estimated_arrival, :greater_than_or_equal_to, count: Date.current)
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
