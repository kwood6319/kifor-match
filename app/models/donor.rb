class Donor < ApplicationRecord
  include RegionPrefecture

  belongs_to :user
  has_many :offers, dependent: :restrict_with_error
  has_many :notifications, as: :recipient
end
