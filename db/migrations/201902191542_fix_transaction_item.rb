Sequel.migration do
  up do
    alter_table(:mr_inventory_transaction_items) do
      add_foreign_key :to_location_id, :locations, null: true, key: [:id]
    end
    alter_table(:mr_inventory_transactions) do
      add_column :active, :boolean, default: false
    end
  end

  down do
    alter_table(:mr_inventory_transaction_items) do
      drop_column :to_location_id
    end
    alter_table(:mr_inventory_transactions) do
      drop_column :active
    end
  end
end
