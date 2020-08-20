Sequel.migration do
  up do
    alter_table(:mr_sales_returns) do
      drop_constraint :sales_returns_unique_mr_sales_orders
    end
    alter_table(:mr_sales_return_items) do
      drop_constraint :sales_returns_unique_mr_sales_order_items
      add_unique_constraint [:mr_sales_return_id, :mr_sales_order_item_id], name: :sales_return_items_uniq
    end
    alter_table(:mr_sales_orders) do
      add_column :returned, TrueClass, default: false
    end
    alter_table(:mr_sales_order_items) do
      add_column :returned, TrueClass, default: false
    end
  end

  down do
    alter_table(:mr_sales_returns) do
      add_unique_constraint [:mr_sales_order_id], name: :sales_returns_unique_mr_sales_orders
    end
    alter_table(:mr_sales_return_items) do
      drop_constraint :sales_return_items_uniq
      add_unique_constraint [:mr_sales_order_item_id], name: :sales_returns_unique_mr_sales_order_items
    end
    alter_table(:mr_sales_orders) do
      drop_column :returned
    end
    alter_table(:mr_sales_order_items) do
      drop_column :returned
    end
  end
end
