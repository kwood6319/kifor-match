class RecalculateTopCategoriesJob < ApplicationJob
  queue_as :default

  def perform
    CategoryList.recalculate_top_categories!
  end
end
