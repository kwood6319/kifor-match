class AddRejectionMessageToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :rejection_reason, :text
  end
end
