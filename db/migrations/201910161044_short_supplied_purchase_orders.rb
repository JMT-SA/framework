Sequel.migration do
  up do
    alter_table(:mr_purchase_orders) do
      add_column :short_supplied, TrueClass, default: false
    end
  end

  down do
    alter_table(:mr_purchase_orders) do
      drop_column :short_supplied
    end
  end
end
