Sequel.migration do
  up do
    alter_table(:locations) do
      add_column :can_store_stock, TrueClass, default: false
    end
  end

  down do
    alter_table(:locations) do
      drop_column :can_store_stock
    end
  end
end
