class AddNotNullConstraintsToDonors < ActiveRecord::Migration[8.1]
  def change
    change_column_null :donors, :display_name, false
  end
end
