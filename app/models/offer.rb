class Offer < ApplicationRecord
  belongs_to :request
  belongs_to :donor_profile
end
