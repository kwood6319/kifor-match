class AddShippingToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :estimated_arrival, :date
  end
end
