class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.references :request, null: false, foreign_key: true
      t.references :donor_profile, null: false, foreign_key: true
      t.integer :quantity_offered
      t.string :condition
      t.text :message
      t.date :can_ship_by
      t.string :tracking_number
      t.string :status

      t.timestamps
    end
  end
end
