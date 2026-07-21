class AddActiveToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :active, :boolean, default: true, null: false
  end
end
