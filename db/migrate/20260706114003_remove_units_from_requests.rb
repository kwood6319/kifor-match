class RemoveUnitsFromRequests < ActiveRecord::Migration[8.1]
  def change
    remove_column :requests, :units, :string
  end
end
