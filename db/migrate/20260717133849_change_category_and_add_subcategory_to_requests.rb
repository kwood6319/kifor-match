class ChangeCategoryAndAddSubcategoryToRequests < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      ALTER TABLE requests
      ALTER COLUMN category TYPE varchar[]
      USING CASE
        WHEN category IS NULL THEN '{}'::varchar[]
        ELSE ARRAY[category]
      END
    SQL

    change_column_default :requests, :category, from: nil, to: []

    add_column :requests, :subcategory, :string, array: true, default: []
  end

  def down
    execute <<-SQL
      ALTER TABLE requests
      ALTER COLUMN category TYPE varchar
      USING category[1]
    SQL

    remove_column :requests, :subcategory
  end
end
