Sequel.migration do
  up do
    alter_table(:mr_deliveries) do
      add_column :invoice_completed_by, String
      add_column :invoice_completed_at, DateTime
    end

    alter_table(:mr_goods_returned_notes) do
      add_column :invoice_completed_by, String
      add_column :invoice_completed_at, DateTime
    end

    alter_table(:mr_sales_orders) do
      add_column :invoice_completed_by, String
      add_column :invoice_completed_at, DateTime
    end

    run <<~SQL
      UPDATE mr_deliveries
      SET invoice_completed_by = (SELECT fn_get_latest_user_for_status('mr_deliveries', 'PURCHASE INVOICE COMPLETED', mr_deliveries.id)),
          invoice_completed_at = (SELECT fn_get_latest_timestamp_for_status('mr_deliveries', 'PURCHASE INVOICE COMPLETED', mr_deliveries.id));
      
      UPDATE mr_goods_returned_notes
      SET invoice_completed_by = (SELECT fn_get_latest_user_for_status('mr_goods_returned_notes', 'PURCHASE INVOICE COMPLETED', mr_goods_returned_notes.id)),
          invoice_completed_at = (SELECT fn_get_latest_timestamp_for_status('mr_goods_returned_notes', 'PURCHASE INVOICE COMPLETED', mr_goods_returned_notes.id));
      
      UPDATE mr_sales_orders
      SET invoice_completed_by = (SELECT fn_get_latest_user_for_status('mr_sales_orders', 'SALES ORDER COMPLETED', mr_sales_orders.id)),
          invoice_completed_at = (SELECT fn_get_latest_timestamp_for_status('mr_sales_orders', 'SALES ORDER COMPLETED', mr_sales_orders.id));
    SQL
  end

  down do
    alter_table(:mr_deliveries) do
      drop_column :invoice_completed_by, String
      drop_column :invoice_completed_at, DateTime
    end

    alter_table(:mr_goods_returned_notes) do
      drop_column :invoice_completed_by, String
      drop_column :invoice_completed_at, DateTime
    end

    alter_table(:mr_sales_orders) do
      drop_column :invoice_completed_by, String
      drop_column :invoice_completed_at, DateTime
    end
  end
end
