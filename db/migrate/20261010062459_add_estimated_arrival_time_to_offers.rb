class AddEstimatedArrivalTimeToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :estimated_arrival_time, :string
  end
end
