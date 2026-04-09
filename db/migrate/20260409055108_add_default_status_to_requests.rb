class AddDefaultStatusToRequests < ActiveRecord::Migration[8.1]
  def change
    change_column_default :requests, :status, from: nil, to: "inactive"
    change_column_null :requests, :status, false, "inactive"
  end
end
