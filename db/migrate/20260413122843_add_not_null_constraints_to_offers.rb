class AddNotNullConstraintsToOffers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :offers, :condition, false
    change_column_null :offers, :quantity_offered, false
    change_column_default :offers, :status, from: nil, to: "submitted"
    change_column_null :offers, :status, false, "submitted"
  end
end
