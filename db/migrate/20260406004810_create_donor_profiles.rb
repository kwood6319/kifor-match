class CreateDonorProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :donor_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :display_name
      t.string :donor_type
      t.string :region
      t.string :city

      t.timestamps
    end
  end
end
