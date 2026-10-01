class AddArchivedAtToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :archived_at, :datetime
  end
end
