class AddFlagReasonToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :flag_reason, :text
  end
end
