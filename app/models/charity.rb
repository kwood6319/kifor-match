class Charity < ApplicationRecord
  belongs_to :user
  has_many :requests, dependent: :restrict_with_error
  has_many :notifications, as: :recipient
  # Holds the charity's region/prefecture (its public location) and shipping address
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, update_only: true

  delegate :region, :prefecture, to: :address, allow_nil: true

  validates :org_name, :address, presence: true

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
