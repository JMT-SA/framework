Sequel.migration do
  up do
    alter_table(:mr_delivery_items) do
      add_column :quantity_difference, BigDecimal, size: [12, 2], default: 0
    end
    alter_table(:mr_deliveries) do
      add_column :accepted_qty_difference, TrueClass, default: false
      add_column :reviewed, TrueClass, default: false
    end
  end

  down do
    alter_table(:mr_delivery_items) do
      drop_column :quantity_difference
    end
    alter_table(:mr_deliveries) do
      drop_column :accepted_qty_difference
      drop_column :reviewed
    end
  end
end
