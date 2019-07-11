Sequel.migration do
  up do
    alter_table(:mr_delivery_items) do
      add_column :quantity_returned, BigDecimal, size: [7, 2], default: 0
    end
  end

  down do
    alter_table(:mr_delivery_items) do
      drop_column :quantity_returned
    end
  end
end
