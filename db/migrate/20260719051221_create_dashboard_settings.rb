class CreateDashboardSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :dashboard_settings do |t|
      t.string :top_categories, array: true, default: []
      t.datetime :top_categories_updated_at
      t.timestamps
    end
  end
end
