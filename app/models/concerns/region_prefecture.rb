# Keeps a profile's prefecture inside its region (no Shikoku - Tokyo).
module RegionPrefecture
  extend ActiveSupport::Concern

  included do
    validates :region, inclusion: { in: Request::REGIONS }, allow_blank: true
    validate :prefecture_in_region, if: -> { prefecture.present? }
  end

  private

  def prefecture_in_region
    return if Request::REGIONS_AND_PREFECTURES.fetch(region, []).include?(prefecture)

    errors.add(:prefecture, :inclusion)
  end
end
