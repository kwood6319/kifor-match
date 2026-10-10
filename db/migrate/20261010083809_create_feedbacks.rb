# A charity's feedback on a donation it received. One per offer; the request,
# charity and donor are all reached through the offer.
class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :offer, null: false, foreign_key: true, index: { unique: true }
      t.string :tags, array: true, default: [], null: false
      t.text :comment
      t.boolean :escalated, default: false, null: false

      t.timestamps
    end
  end
end
