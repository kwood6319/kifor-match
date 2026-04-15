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

  REGIONS_AND_CITIES = {
    "Hokkaido" => %w[Sapporo Hakodate Asahikawa Kushiro Obihiro],
    "Tohoku"   => %w[Sendai Morioka Akita Yamagata Fukushima Aomori],
    "Kanto"    => %w[Tokyo Yokohama Kawasaki Saitama Chiba Utsunomiya Mito Maebashi],
    "Chubu"    => %w[Nagoya Shizuoka Niigata Kanazawa Hamamatsu Toyama Nagano Gifu Fukui],
    "Kansai"   => %w[Osaka Kyoto Kobe Nara Otsu Wakayama Himeji],
    "Chugoku"  => %w[Hiroshima Okayama Yamaguchi Matsue Tottori],
    "Shikoku"  => %w[Matsuyama Takamatsu Kochi Tokushima],
    "Kyushu"   => %w[Fukuoka Kitakyushu Kumamoto Kagoshima Nagasaki Oita Miyazaki Saga],
    "Okinawa"  => %w[Naha Okinawa Uruma]
  }.freeze # Freeze makes this object immutable

  REGIONS = REGIONS_AND_CITIES.keys
  CITIES = REGIONS_AND_CITIES.values.flatten

  after_initialize :set_default_status, if: :new_record?
  # Setting qty remaining = qty needed for now
  before_validation :sync_quantity_remaining, on: :create

  validates :title, :category, :description, :units, :condition, :region, :city, :urgency, presence: true
  validates :status, inclusion: { in: STATUSES }
  def set_default_status
    self.status ||= "inactive"
  end

  def sync_quantity_remaining
    # Setting qty remaining = qty needed for now
    self.quantity_remaining = quantity_needed
  end
end
