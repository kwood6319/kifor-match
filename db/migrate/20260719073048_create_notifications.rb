class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.string :type, null: false
      t.references :offer, null: true, foreign_key: true
      t.boolean :dismissed, default: false, null: false
      t.timestamps
    end

    add_index :notifications, [:recipient_type, :recipient_id, :dismissed]
  end
end
