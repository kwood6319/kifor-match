class Donor < ApplicationRecord
  belongs_to :user
  has_many :offers
  has_many :notifications, as: :recipient
end
