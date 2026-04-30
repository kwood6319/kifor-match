class AddApprovedToCharities < ActiveRecord::Migration[8.1]
  def change
    add_column :charities, :approved, :boolean, default: false
  end
end
