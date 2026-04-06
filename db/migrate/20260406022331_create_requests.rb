class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.references :charity, null: false, foreign_key: true
      t.string :title
      t.string :category
      t.text :description
      t.integer :quantity_needed
      t.integer :quantity_remaining
      t.string :units
      t.string :condition
      t.string :region
      t.string :city
      t.string :urgency
      t.string :status

      t.timestamps
    end
  end
end
