class Donor < ApplicationRecord
  belongs_to :user
  has_many :offers, dependent: :restrict_with_error
  has_many :notifications, as: :recipient
end
