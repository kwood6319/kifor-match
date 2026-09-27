class Charity < ApplicationRecord
  include RegionPrefecture

  belongs_to :user
  has_many :requests, dependent: :restrict_with_error
  has_many :notifications, as: :recipient

  # TO DO: Replace with an accepts_drop_off boolean column on charities (and a
  # settings toggle). Hardcoded demo placeholder until then.
  NO_DROP_OFF_ORG_NAMES = [
    "Osaka Food Support (DEMO)",
    "Refugee Children"
  ].freeze

  def accepts_drop_off?
    NO_DROP_OFF_ORG_NAMES.exclude?(org_name)
  end

  # TO DO: Replace with an accepts_shipping boolean column on charities.
  # Every charity accepts shipping for now.
  def accepts_shipping?
    true
  end
end
