# One day a week a charity takes drop-offs, e.g. Monday 9:00-17:00.
class DropOffWindow < ApplicationRecord
  belongs_to :charity

  # Days as Date#wday numbers, Monday first as weekly schedules are usually shown
  WEEK_ORDER = [1, 2, 3, 4, 5, 6, 0].freeze

  # Set on the unsaved rows the settings form builds for closed days
  attr_accessor :placeholder

  validates :day_of_week, inclusion: { in: 0..6 }, uniqueness: { scope: :charity_id }
  validates :opens_at, :closes_at, presence: true
  validate :closes_after_opens

  private

  def closes_after_opens
    return if opens_at.blank? || closes_at.blank? || closes_at > opens_at

    errors.add(:closes_at, :after_opening)
  end
end
