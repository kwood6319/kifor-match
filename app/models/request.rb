class Request < ApplicationRecord
  belongs_to :charity
  has_many :offers
  include CategoryList

  STATUSES = %w[
    active
    fulfilled
    flagged
  ]

  CONDITIONS = [
    "new",
    "used_like_new",
    "used_very_good",
    "used_good"
  ].freeze

  # CATEGORIES = %w[
  #   food
  #   stationery
  #   hygiene
  #   clothes
  #   baby
  #   cooking
  #   cleaning
  #   seasonal
  #   other
  #   electronics
  #   necessities
  # ]

  # UNITS = %w[
  #   item
  #   box
  #   pack
  #   kg
  #   liter
  #   pair
  #   set
  # ]

  URGENCIES = %w[
    low
    medium
    high
    urgent
  ]

  REGIONS_AND_PREFECTURES = {
    "Hokkaido" => %w[Hokkaido],
    "Tohoku" => %w[Aomori Iwate Miyagi Akita Yamagata Fukushima],
    "Kanto" => %w[Ibaraki Tochigi Gunma Saitama Chiba Tokyo Kanagawa],
    "Chubu" => %w[Niigata Toyama Ishikawa Fukui Yamanashi Nagano Gifu Shizuoka Aichi],
    "Kansai" => %w[Mie Shiga Kyoto Osaka Hyogo Nara Wakayama],
    "Chugoku" => %w[Tottori Shimane Okayama Hiroshima Yamaguchi],
    "Shikoku" => %w[Tokushima Kagawa Ehime Kochi],
    "Kyushu" => %w[Fukuoka Saga Nagasaki Kumamoto Oita Miyazaki Kagoshima],
    "Okinawa" => %w[Okinawa]
  }.freeze # Freeze makes this object immutable

  REGIONS = REGIONS_AND_PREFECTURES.keys
  PREFECTURES = REGIONS_AND_PREFECTURES.values.flatten

  after_initialize :set_default_status, if: :new_record?
  # Setting qty remaining = qty needed for now
  before_validation :sync_quantity_remaining, on: :create

  validates :title, :description, :condition, :urgency, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :quantity_needed, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity_remaining, numericality: { greater_than_or_equal_to: 0 }

  validate :categories_are_valid
  validate :subcategories_are_valid

  def set_default_status
    self.status ||= "active"
  end

  def sync_quantity_remaining
    # Setting qty remaining = qty needed for now
    self.quantity_remaining = quantity_needed
  end

  def acceptable_conditions
    index = CONDITIONS.index(condition)
    CONDITIONS[0..index]
  end

  private

  def categories_are_valid
    invalid = category - CategoryList::CATEGORIES.keys
    errors.add(:category, "contains invalid values: #{invalid.join(', ')}") if invalid.any?
  end

  def subcategories_are_valid
    return if subcategory.blank?

    allowed = category.flat_map { |cat| CategoryList.subcategories_for(cat) }
    invalid = subcategory - allowed
    errors.add(:subcategory, "contains invalid values: #{invalid, join(', ')}") if invalid.any?
  end
end
