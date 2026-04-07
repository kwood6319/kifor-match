class Request < ApplicationRecord
  belongs_to :charity
  has_many :offers
end
