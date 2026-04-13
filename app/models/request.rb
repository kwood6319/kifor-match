class Request < ApplicationRecord
  belongs_to :charity
  has_many :offers

  STATUSES = %w[active inactive fulfilled submitted]

  after_initialize :set_default_status, if: :new_record?

  validates :title, :category, :description, :units, :condition, :region, :city, :urgency, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :quantity_needed, :quantity_remaining, numericality: { greater_than_or_equal_to: 0 }

  private

  def set_default_status
    self.status ||= "inactive"
  end
end
