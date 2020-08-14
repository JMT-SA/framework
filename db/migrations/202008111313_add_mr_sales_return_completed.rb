Sequel.migration do
  up do
    alter_table(:mr_sales_returns) do
      add_column :completed, TrueClass, default: false
      add_column :completed_by, String
      add_column :completed_at, DateTime
      add_column :verified, TrueClass, default: false
      add_column :verified_by, String
      add_column :verified_at, DateTime
    end
  end

  down do
    alter_table(:mr_sales_returns) do
      drop_column :completed
      drop_column :completed_by
      drop_column :completed_at
      drop_column :verified
      drop_column :verified_by
      drop_column :verified_at
    end
  end
end
