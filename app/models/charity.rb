class Charity < ApplicationRecord
  belongs_to :user
  has_many :requests, dependent: :restrict_with_error
  has_many :notifications, as: :recipient
  # Holds the charity's region/prefecture (its public location) and shipping address
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, update_only: true

  # Days and hours the charity takes drop-offs (only used when accepts_drop_off is on).
  # The settings form sends all seven days; unticked ones are destroyed or never built.
  has_many :drop_off_windows, -> { order(:day_of_week) }, dependent: :destroy, inverse_of: :charity
  accepts_nested_attributes_for :drop_off_windows, allow_destroy: true

  delegate :region, :prefecture, to: :address, allow_nil: true

  # Settings checkbox: "also allow drop-off on my current needs" (not stored)
  attribute :apply_drop_off_to_open_needs, :boolean, default: false
  after_save :allow_drop_off_on_open_needs, if: -> { accepts_drop_off? && apply_drop_off_to_open_needs? }

  validates :org_name, :address, presence: true
  validate :drop_off_needs_open_days, if: :accepts_drop_off?
  validate :accepts_some_delivery
  # Turning shipping or drop-off off mustn't leave an open need with no way to receive donations
  validate :open_needs_stay_reachable, if: -> { will_save_change_to_accepts_shipping? || will_save_change_to_accepts_drop_off? }

  # Open needs: not archived and still needing items (what donors can offer on)
  def open_requests
    requests.where.not(status: "archived").where("quantity_remaining > 0")
  end

  private

  def allow_drop_off_on_open_needs
    open_requests.where(allows_drop_off: false).update_all(allows_drop_off: true, updated_at: Time.current)
  end

  def accepts_some_delivery
    errors.add(:base, :no_delivery_method) unless accepts_shipping? || accepts_drop_off?
  end

  # Uses the new (unsaved) settings: a need is reachable by shipping, or by drop-off if it allows it.
  # Archived needs and ones that already have everything aren't taking donations, so they're skipped.
  def open_needs_stay_reachable
    # With both off, accepts_some_delivery already explains the problem
    return if accepts_shipping? || !accepts_drop_off?
    return if apply_drop_off_to_open_needs? # they're all about to allow drop-off

    stranded = open_requests.reject(&:allows_drop_off?)
    return if stranded.empty?

    errors.add(:base, :needs_without_delivery, titles: quoted_titles(stranded))
  end

  # Names the first two, then counts the rest so the message stays readable:
  # “A”, “B” and 3 more / 「A」、「B」ほか3件
  def quoted_titles(requests, shown: 2)
    ja = I18n.locale == :ja
    names = requests.first(shown).map { |request| ja ? "「#{request.title}」" : "“#{request.title}”" }
    list = names.join(ja ? "、" : ", ")
    rest = requests.size - shown
    rest.positive? ? I18n.t("errors.messages.and_more", list: list, count: rest) : list
  end

  def drop_off_needs_open_days
    return if drop_off_windows.any? { |window| !window.marked_for_destruction? }

    errors.add(:drop_off_windows, :no_open_days)
  end
end
