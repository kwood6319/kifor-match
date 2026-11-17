# A Japanese postal address, split the way Japanese forms present it:
# postal code, prefecture, city, street (町名・番地), building.
class Address < ApplicationRecord
  include RegionPrefecture

  belongs_to :addressable, polymorphic: true

  # Suffix that completes a prefecture's name on a label (東京 -> 東京都); every other one is 県
  PREFECTURE_SUFFIXES = { "Hokkaido" => "", "Tokyo" => "都", "Osaka" => "府", "Kyoto" => "府" }.freeze

  # What the onboarding and settings forms may set
  FORM_FIELDS = %i[postal_code region prefecture city street building recipient_name].freeze

  # Accept full-width digits and "150-0001" style input; store "1500001"
  normalizes :postal_code, with: ->(code) { code.unicode_normalize(:nfkc).gsub(/\D/, "") }
  normalizes :city, :street, :building, :recipient_name, with: :strip.to_proc

  validates :postal_code, :region, :prefecture, :city, :street, presence: true
  validates :postal_code, format: { with: /\A\d{7}\z/ }, allow_blank: true

  # "150-0001"; anything that isn't 7 digits (e.g. a typo being corrected) as typed
  def formatted_postal_code
    return postal_code unless postal_code.to_s.match?(/\A\d{7}\z/)

    "#{postal_code[0, 3]}-#{postal_code[3..]}"
  end

  # Full prefecture name as written on a Japanese shipping label, e.g. 東京都, 大阪府, 北海道, 石川県
  def prefecture_ja
    I18n.t("prefectures.#{prefecture}", locale: :ja) + PREFECTURE_SUFFIXES.fetch(prefecture, "県")
  end

  # The 住所 box of a shipping slip: prefecture, city and street run together, then the building
  def label_address
    [[prefecture_ja, city, street].join, building].compact_blank.join(" ")
  end
end
