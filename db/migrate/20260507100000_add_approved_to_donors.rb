class AddApprovedToDonors < ActiveRecord::Migration[8.1]
  def change
    add_column :donors, :approved, :boolean, default: false
  end
end
