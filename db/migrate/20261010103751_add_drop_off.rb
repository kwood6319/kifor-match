# How donations reach a charity: shipping (on by default) and/or drop-off.
# - Charities choose which they accept, and set which days/hours they take drop-offs.
# - Each request then opts in, so a charity can allow drop-off for some needs only.
# - Each offer records which way the donor chose.
class AddDropOff < ActiveRecord::Migration[8.1]
  def change
    add_column :charities, :accepts_shipping, :boolean, default: true, null: false
    add_column :charities, :accepts_drop_off, :boolean, default: false, null: false
    add_column :requests, :allows_drop_off, :boolean, default: false, null: false
    add_column :offers, :delivery_method, :string, default: "shipping", null: false

    # One row per day the charity is open for drop-offs
    create_table :drop_off_windows do |t|
      t.references :charity, null: false, foreign_key: true, index: false # covered by the unique index below
      t.integer :day_of_week, null: false # 0 = Sunday ... 6 = Saturday, like Date#wday
      t.time :opens_at, null: false
      t.time :closes_at, null: false

      t.timestamps
    end
    add_index :drop_off_windows, %i[charity_id day_of_week], unique: true
  end
end
