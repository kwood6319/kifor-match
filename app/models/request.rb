class Request < ApplicationRecord
  belongs_to :charity
  has_many :offers

  STATUSES = %w[
    submitted
    active
    inactive
    fulfilled
  ]

  CONDITIONS = [
    "new",
    "used_like_new",
    "used_very_good",
    "used_good"
  ].freeze

  CATEGORIES = %w[
    food
    stationery
    hygiene
    clothes
    baby
    cooking
    cleaning
    seasonal
    other
    electronics
    necessities
  ]

  UNITS = %w[
    item
    box
    pack
    kg
    liter
    pair
    set
  ]

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

  validates :title, :category, :description, :units, :condition, :urgency, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :quantity_needed, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity_remaining, numericality: { greater_than_or_equal_to: 0 }


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
end
