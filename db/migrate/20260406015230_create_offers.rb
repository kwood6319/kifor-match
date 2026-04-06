class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.integer :request_id
      t.integer :donor_profile_id
      t.integer :quantity_offered
      t.string :condition
      t.string :message
      t.date :can_ship_by
      t.string :tracking_number
      t.string :status

      t.timestamps
    end
  end
end
