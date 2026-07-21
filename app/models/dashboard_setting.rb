class DashboardSetting < ApplicationRecord
  def self.instance
    first_or_create!
  end

  def self.top_categories
    instance.top_categories.presence || CategoryList::CATEGORIES.keys.first(8)
  end
end
