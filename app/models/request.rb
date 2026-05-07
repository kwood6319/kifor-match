class Request < ApplicationRecord
  belongs_to :charity
  has_many :offers

  STATUSES = %w[
    submitted
    active
    inactive
    fulfilled
  ]

  CONDITIONS = %w[
    New
    Used_-_Like_New
    Used_-_Good
  ]

  CATEGORIES = %w[
    Food
    Stationery
    Hygiene
    Clothes
    Baby
    Cooking
    Cleaning
    Seasonal
    Other
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
    "Tohoku"   => %w[Aomori Iwate Miyagi Akita Yamagata Fukushima],
    "Kanto"    => %w[Ibaraki Tochigi Gunma Saitama Chiba Tokyo Kanagawa],
    "Chubu"    => %w[Niigata Toyama Ishikawa Fukui Yamanashi Nagano Gifu Shizuoka Aichi],
    "Kansai"   => %w[Mie Shiga Kyoto Osaka Hyogo Nara Wakayama],
    "Chugoku"  => %w[Tottori Shimane Okayama Hiroshima Yamaguchi],
    "Shikoku"  => %w[Tokushima Kagawa Ehime Kochi],
    "Kyushu"   => %w[Fukuoka Saga Nagasaki Kumamoto Oita Miyazaki Kagoshima],
    "Okinawa"  => %w[Okinawa]
  }.freeze # Freeze makes this object immutable

  REGIONS = REGIONS_AND_PREFECTURES.keys
  PREFECTURES = REGIONS_AND_PREFECTURES.values.flatten

  after_initialize :set_default_status, if: :new_record?
  # Setting qty remaining = qty needed for now
  before_validation :sync_quantity_remaining, on: :create

  validates :title, :category, :description, :units, :condition, :urgency, presence: true
  validates :status, inclusion: { in: STATUSES }
  def set_default_status
    self.status ||= "inactive"
  end

  def sync_quantity_remaining
    # Setting qty remaining = qty needed for now
    self.quantity_remaining = quantity_needed
  end
end
