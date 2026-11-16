class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :addressable, polymorphic: true, null: false, index: { unique: true }
      t.string :postal_code, null: false
      t.string :region, null: false
      t.string :prefecture, null: false
      t.string :city, null: false
      t.string :street, null: false
      t.string :building
      t.string :recipient_name

      t.timestamps
    end

    remove_column :charities, :region, :string, null: false
    remove_column :charities, :prefecture, :string
    remove_column :charities, :shipping_address, :text
  end
end
