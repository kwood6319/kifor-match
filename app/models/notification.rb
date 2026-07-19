class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  belongs_to :offer, optional: true

  scope :undismissed, -> { where(dismissed: false) }

  def message
    raise NotImplementedError, "#{self.class} must implement #message."
  end

  def link_path
    raise NotImplementedError, "#{self.class} must implement #link_path"
  end
end
