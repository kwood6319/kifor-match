class AddLocaleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :locale, :string, default: "en", null: false
  end
end
