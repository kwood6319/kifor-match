# Snapshot of where/when to hand an offer over (address, recipient, drop-off hours),
# taken when the charity approves it. Later settings changes don't reach offers in
# progress; the charity is warned about this in settings.
class AddDeliveryDetailsToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :delivery_details, :jsonb
  end
end
