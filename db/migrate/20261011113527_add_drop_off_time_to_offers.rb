# The time a donor plans to drop off, alongside the planned date (estimated_arrival).
# Shipping keeps its courier time window (estimated_arrival_time) instead.
class AddDropOffTimeToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :drop_off_time, :time
  end
end
