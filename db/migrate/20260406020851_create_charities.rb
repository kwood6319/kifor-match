class CreateCharities < ActiveRecord::Migration[8.1]
  def change
    create_table :charities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :org_name
      t.text :description
      t.string :region
      t.string :city
      t.text :shipping_address

      t.timestamps
    end
  end
end
