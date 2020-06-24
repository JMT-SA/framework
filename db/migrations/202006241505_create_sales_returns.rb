require 'sequel_postgresql_triggers'
Sequel.migration do
  change do
    extension :pg_triggers
    create_table(:mr_sales_returns, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_sales_order_id, :mr_sales_orders, null: false, key: [:id]
      foreign_key :issue_transaction_id, :mr_inventory_transactions, key: [:id]

      String :created_by, null: false
      String :remarks, text: true
      Integer :sr_credit_note_number, null: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_sales_order_id], name: :sales_returns_unique_mr_sales_orders, unique: true
    end
    run 'CREATE SEQUENCE doc_seqs_sr_credit_note_number;'

    pgt_created_at(:mr_sales_returns,
                   :created_at,
                   function_name: :mr_sales_returns_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_sales_returns,
                   :updated_at,
                   function_name: :mr_sales_returns_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:mr_sales_return_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_sales_return_id, :mr_sales_returns, null: false, key: [:id]
      foreign_key :mr_sales_order_item_id, :mr_sales_order_items, key: [:id]

      String :remarks, text: true
      BigDecimal :quantity_returned, size: [12, 2]

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_sales_order_item_id], name: :sales_returns_unique_mr_sales_order_items, unique: true
    end
    pgt_created_at(:mr_sales_return_items,
                   :created_at,
                   function_name: :mr_sales_return_items_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_sales_return_items,
                   :updated_at,
                   function_name: :mr_sales_return_items_set_updated_at,
                   trigger_name: :set_updated_at)

  end

  down do
    run 'DROP SEQUENCE doc_seqs_sr_credit_note_number;'

    drop_trigger(:mr_sales_return_items, :set_created_at)
    drop_function(:mr_sales_return_items_set_created_at)
    drop_trigger(:mr_sales_return_items, :set_updated_at)
    drop_function(:mr_sales_return_items_set_updated_at)
    drop_table(:mr_sales_return_items)

    drop_trigger(:mr_sales_returns, :set_created_at)
    drop_function(:mr_sales_returns_set_created_at)
    drop_trigger(:mr_sales_returns, :set_updated_at)
    drop_function(:mr_sales_returns_set_updated_at)
    drop_table(:mr_sales_returns)
  end
end
