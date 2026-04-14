class AddNotNullConstraintsToCharities < ActiveRecord::Migration[8.1]
  def change
    change_column_null :charities, :org_name, false
    change_column_null :charities, :region, false
  end
end
