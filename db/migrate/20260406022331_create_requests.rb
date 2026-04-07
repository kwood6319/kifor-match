class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.references :charity, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category, null: false
      t.text :description
      t.integer :quantity_needed, null: false
      t.integer :quantity_remaining, null: false
      t.string :units, null: false
      t.string :condition, null: false
      t.string :region, null: false
      t.string :city
      t.string :urgency, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
