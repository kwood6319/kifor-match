class Charity < ApplicationRecord
  belongs_to :user
  has_many :requests, dependent: :restrict_with_error
end
