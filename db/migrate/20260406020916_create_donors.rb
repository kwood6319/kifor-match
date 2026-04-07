class CreateDonors < ActiveRecord::Migration[8.1]
  def change
    create_table :donors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :display_name, null: false
      t.string :donor_type
      t.string :region
      t.string :city

      t.timestamps
    end
  end
end
