class AddDefaultStatusToRequests < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL.squish
      UPDATE requests SET units = 'pairs' WHERE title = 'Shoes' AND units IS NULL;
      UPDATE requests SET units = 'portion(s)' WHERE title = 'Non-perishables' AND units IS NULL;
      UPDATE requests SET urgency = 'medium' WHERE urgency IS NULL;
    SQL

    change_column_null :requests, :category, false
    change_column_null :requests, :condition, false
    change_column_null :requests, :quantity_needed, false
    change_column_null :requests, :quantity_remaining, false
    change_column_null :requests, :region, false
    change_column_null :requests, :title, false
    change_column_null :requests, :units, false
    change_column_null :requests, :urgency, false
    change_column_default :requests, :status, from: nil, to: "inactive"
    change_column_null :requests, :status, false, "inactive"
  end

  def down
    change_column_null :requests, :category, true
    change_column_null :requests, :condition, true
    change_column_null :requests, :quantity_needed, true
    change_column_null :requests, :quantity_remaining, true
    change_column_null :requests, :region, true
    change_column_null :requests, :title, true
    change_column_null :requests, :units, true
    change_column_null :requests, :urgency, true
    change_column_default :requests, :status, from: "inactive", to: nil
    change_column_null :requests, :status, true
  end
end
