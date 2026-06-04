class ChangeRequestStatusDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :requests, :status, from: "inactive", to: "active"
  end
end
