class RenameCityToPrefecture < ActiveRecord::Migration[8.1]
  def change
    rename_column :charities, :city, :prefecture
    rename_column :donors, :city, :prefecture
    rename_column :requests, :city, :prefecture
  end
end
