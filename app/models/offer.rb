class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :donor

  has_one_attached :photo
end
