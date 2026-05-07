class RemoveLocationFromRequests < ActiveRecord::Migration[8.1]
  def change
    remove_column :requests, :region, :string, null: false
    remove_column :requests, :prefecture, :string
  end
end
